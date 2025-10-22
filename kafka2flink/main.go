package main

import (
    "context"
    "encoding/json"
    "fmt"
    "log"
    "sort"
    "strings"
    "time"

    "github.com/gocql/gocql"
    "github.com/segmentio/kafka-go"
)

type TelemetryRecord struct {
    VehicleID         string  `json:"vehicleId"`
    SessionID         string  `json:"sessionId"`
    Timestamp         float64 `json:"timestamp"`
    ChannelID         int     `json:"channelId"`
    ChannelName       string  `json:"channelName"`
    ChannelValue      float64 `json:"channelValue"`
    ChannelUnit       string  `json:"channelUnit"`
    ChannelMinValue   string  `json:"channelMinValue"`
    ChannelMaxValue   string  `json:"channelMaxValue"`
    ChannelMultiplier float64 `json:"channelMultiplier"`
    ChannelGroup      string  `json:"channelGroup"`
    ChannelCount      int     `json:"channelCount"`
    ExpectedFrequency string  `json:"expectedFrequency"`
    ActualFrequency   float64 `json:"actualFrequency"`
    UpdateInterval    int     `json:"updateInterval"`
    FrequencyLabel    string  `json:"frequencyLabel"`
    Semantic          string  `json:"semantic"`
}

func sanitizeTableName(topic string) string {
    table := strings.ReplaceAll(topic, "-", "_")
    table = strings.ReplaceAll(table, ".", "_")
    return "telemetry_" + table
}

func getLatestTopic(broker string, prefix string) (string, error) {
    conn, err := kafka.Dial("tcp", broker)
    if err != nil {
        return "", err
    }
    defer conn.Close()

    partitions, err := conn.ReadPartitions()
    if err != nil {
        return "", err
    }

    topicsMap := make(map[string]struct{})
    for _, p := range partitions {
        if strings.HasPrefix(p.Topic, prefix) {
            topicsMap[p.Topic] = struct{}{}
        }
    }

    if len(topicsMap) == 0 {
        return "", fmt.Errorf("no topics found with prefix %s", prefix)
    }

    topics := make([]string, 0, len(topicsMap))
    for t := range topicsMap {
        topics = append(topics, t)
    }

    sort.Strings(topics)
    return topics[len(topics)-1], nil
}

func createTelemetryTable(session *gocql.Session, tableName string) error {
    query := fmt.Sprintf(`
        CREATE TABLE IF NOT EXISTS %s (
            vehicle_id text,
            session_id text,
            timestamp double,
            channel_id int,
            channel_name text,
            channel_value double,
            channel_unit text,
            channel_min_value text,
            channel_max_value text,
            channel_multiplier double,
            channel_group text,
            channel_count int,
            expected_frequency text,
            actual_frequency double,
            update_interval int,
            frequency_label text,
            semantic text,
            PRIMARY KEY ((vehicle_id, session_id), timestamp, channel_id)
        ) WITH CLUSTERING ORDER BY (timestamp ASC, channel_id ASC);
    `, tableName)
    return session.Query(query).Exec()
}

func main() {
    log.Println("[DEBUG] Starting Kafka -> Cassandra telemetry consumer")

    ctx := context.Background()

    kafkaBrokers := []string{"localhost:9092"}
    kafkaTopicPrefix := "p424-telemetry-batch-"

    // --- Get latest topic ---
    kafkaTopic, err := getLatestTopic(kafkaBrokers[0], kafkaTopicPrefix)
    if err != nil {
        log.Fatalf("[ERROR] Cannot find latest Kafka topic: %v", err)
    }
    log.Printf("[DEBUG] Using latest Kafka topic: %s", kafkaTopic)

    tableName := sanitizeTableName(kafkaTopic)
    log.Printf("[DEBUG] Cassandra table will be: %s", tableName)

    // --- Connect to cluster (no keyspace yet) ---
    cluster := gocql.NewCluster("localhost")
    cluster.Consistency = gocql.Quorum
    cluster.Timeout = 5 * time.Second

    session, err := cluster.CreateSession()
    if err != nil {
        log.Fatalf("[ERROR] Failed to connect to Cassandra: %v", err)
    }
    defer session.Close()
    log.Println("[DEBUG] Connected to Cassandra cluster (no keyspace yet)")

    // --- Create keyspace if it doesn't exist ---
    keyspace := "telemetry"
    createKeyspaceCQL := fmt.Sprintf(`
        CREATE KEYSPACE IF NOT EXISTS %s
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
    `, keyspace)

    if err := session.Query(createKeyspaceCQL).Exec(); err != nil {
        log.Fatalf("[ERROR] Failed to create keyspace: %v", err)
    }
    log.Printf("[DEBUG] Keyspace '%s' is ready", keyspace)

    // --- Reconnect using the keyspace ---
    session.Close() // close previous session

    cluster.Keyspace = keyspace
    session, err = cluster.CreateSession()
    if err != nil {
        log.Fatalf("[ERROR] Failed to connect to Cassandra keyspace %s: %v", keyspace, err)
    }
    defer session.Close()
    log.Println("[DEBUG] Cassandra session established with keyspace")

    // --- Create table dynamically ---
    if err := createTelemetryTable(session, tableName); err != nil {
        log.Fatalf("[ERROR] Failed to create Cassandra table: %v", err)
    }
    log.Println("[DEBUG] Cassandra table ready")

    // --- Kafka reader ---
    r := kafka.NewReader(kafka.ReaderConfig{
        Brokers:  kafkaBrokers,
        Topic:    kafkaTopic,
        GroupID:  "go-telemetry-consumer",
        MinBytes: 1,
        MaxBytes: 10e6,
    })
    defer r.Close()

    log.Println("[DEBUG] Kafka -> Cassandra pipeline started...")

    // --- Main loop ---
    for {
        msg, err := r.ReadMessage(ctx)
        if err != nil {
            log.Println("[ERROR] Error reading Kafka message:", err)
            continue
        }
        log.Printf("[DEBUG] Received Kafka message (size=%d bytes)", len(msg.Value))

        var records []TelemetryRecord
        if err := json.Unmarshal(msg.Value, &records); err != nil {
            log.Println("[ERROR] Failed to unmarshal JSON:", err)
            continue
        }
        log.Printf("[DEBUG] Unmarshalled %d telemetry records", len(records))

        for _, rec := range records {
            insertQuery := fmt.Sprintf(`
                INSERT INTO %s (
                    vehicle_id, session_id, timestamp, channel_id, channel_name,
                    channel_value, channel_unit, channel_min_value, channel_max_value,
                    channel_multiplier, channel_group, channel_count, expected_frequency,
                    actual_frequency, update_interval, frequency_label, semantic
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, tableName)

            if err := session.Query(insertQuery,
                rec.VehicleID, rec.SessionID, rec.Timestamp, rec.ChannelID,
                rec.ChannelName, rec.ChannelValue, rec.ChannelUnit, rec.ChannelMinValue,
                rec.ChannelMaxValue, rec.ChannelMultiplier, rec.ChannelGroup, rec.ChannelCount,
                rec.ExpectedFrequency, rec.ActualFrequency, rec.UpdateInterval, rec.FrequencyLabel,
                rec.Semantic,
            ).Exec(); err != nil {
                log.Println("[ERROR] Cassandra insert error:", err)
            }
        }
        log.Printf("[DEBUG] Processed %d records", len(records))
    }
}
