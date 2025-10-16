package main

import (
    "context"
    "encoding/json"
    "log"
    "time"

    "github.com/gocql/gocql"
    "github.com/segmentio/kafka-go"
)

type TelemetryRecord struct {
    VehicleID        string  `json:"vehicleId"`
    SessionID        string  `json:"sessionId"`
    Timestamp        float64 `json:"timestamp"`
    ChannelID        int     `json:"channelId"`
    ChannelName      string  `json:"channelName"`
    ChannelValue     float64 `json:"channelValue"`
    ChannelUnit      string  `json:"channelUnit"`
    ChannelMinValue  string  `json:"channelMinValue"`
    ChannelMaxValue  string  `json:"channelMaxValue"`
    ChannelMultiplier float64 `json:"channelMultiplier"`
    ChannelGroup     string  `json:"channelGroup"`
    ChannelCount     int     `json:"channelCount"`
    ExpectedFrequency string `json:"expectedFrequency"`
    ActualFrequency  float64 `json:"actualFrequency"`
    UpdateInterval   int     `json:"updateInterval"`
    FrequencyLabel   string  `json:"frequencyLabel"`
    Semantic         string  `json:"semantic"`
}

func main() {
    log.Println("[DEBUG] Starting Kafka -> Cassandra telemetry consumer")

    ctx := context.Background()

    // Kafka reader config
    kafkaBrokers := []string{"localhost:9092"}
    kafkaTopic := "p424-telemetry-batch"
    log.Printf("[DEBUG] Configuring Kafka reader: brokers=%v, topic=%s\n", kafkaBrokers, kafkaTopic)
    r := kafka.NewReader(kafka.ReaderConfig{
        Brokers:  kafkaBrokers,
        Topic:    kafkaTopic,
        GroupID:  "go-telemetry-consumer",
        MinBytes: 1,
        MaxBytes: 10e6,
    })
    defer r.Close()
    log.Println("[DEBUG] Kafka reader configured")

    // Cassandra session
    cluster := gocql.NewCluster("localhost")
    cluster.Keyspace = "telemetry"
    cluster.Consistency = gocql.Quorum
    cluster.Timeout = 5 * time.Second
    log.Println("[DEBUG] Attempting Cassandra connection...")
    session, err := cluster.CreateSession()
    if err != nil {
        log.Fatalf("[ERROR] Failed to connect to Cassandra: %v", err)
    }
    defer session.Close()
    log.Println("[DEBUG] Cassandra session established")

    // --- Pre-flight checks ---

    // Kafka connectivity check
    log.Println("[DEBUG] Checking Kafka broker connectivity...")
    conn, err := kafka.Dial("tcp", kafkaBrokers[0])
    if err != nil {
        log.Printf("[WARNING] Cannot reach Kafka broker %s: %v", kafkaBrokers[0], err)
    } else {
        log.Printf("[DEBUG] Successfully connected to Kafka broker %s", kafkaBrokers[0])
        conn.Close()
    }

    // Cassandra connectivity check
    log.Println("[DEBUG] Checking Cassandra connectivity...")
    if err := session.Query("SELECT release_version FROM system.local").Exec(); err != nil {
        log.Printf("[WARNING] Cannot reach Cassandra: %v", err)
    } else {
        log.Println("[DEBUG] Cassandra connectivity OK")
    }

    log.Println("[DEBUG] Kafka -> Cassandra pipeline started...")

    for {
        log.Println("[DEBUG] Waiting for Kafka message...")
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
            log.Printf("[DEBUG] Inserting record: vehicle_id=%s, session_id=%s, timestamp=%f, channel_id=%d", rec.VehicleID, rec.SessionID, rec.Timestamp, rec.ChannelID)
            if err := session.Query(`
                INSERT INTO telemetry_full (
                    vehicle_id, session_id, timestamp, channel_id, channel_name,
                    channel_value, channel_unit, channel_min_value, channel_max_value,
                    channel_multiplier, channel_group, channel_count, expected_frequency,
                    actual_frequency, update_interval, frequency_label, semantic
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
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
