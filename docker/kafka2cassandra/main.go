package main

import (
    "context"
    "encoding/json"
    "log"
    "time"

    "github.com/gocql/gocql"
    "github.com/segmentio/kafka-go"
)

// Match your full telemetry schema
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
    ctx := context.Background()

    // Kafka reader config
    kafkaBrokers := []string{"localhost:9092"}
    kafkaTopic := "p424-telemetry-batch"
    r := kafka.NewReader(kafka.ReaderConfig{
        Brokers:  kafkaBrokers,
        Topic:    kafkaTopic,
        GroupID:  "go-telemetry-consumer",
        MinBytes: 1,
        MaxBytes: 10e6,
    })
    defer r.Close()

    // Cassandra session
    cluster := gocql.NewCluster("localhost")
    cluster.Keyspace = "telemetry"
    cluster.Consistency = gocql.Quorum
    cluster.Timeout = 5 * time.Second

    session, err := cluster.CreateSession()
    if err != nil {
        log.Fatalf("Failed to connect to Cassandra: %v", err)
    }
    defer session.Close()

    // --- Pre-flight checks ---

    // --- Kafka connectivity check ---
    conn, err := kafka.Dial("tcp", kafkaBrokers[0])
    if err != nil {
        log.Printf("WARNING: Cannot reach Kafka broker %s: %v", kafkaBrokers[0], err)
    } else {
        log.Printf("Successfully connected to Kafka broker %s", kafkaBrokers[0])
        conn.Close()
    }

    // Cassandra check
    if err := session.Query("SELECT release_version FROM system.local").Exec(); err != nil {
        log.Printf("WARNING: Cannot reach Cassandra: %v", err)
    } else {
        log.Println("Successfully connected to Cassandra")
    }

    log.Println("Kafka -> Cassandra pipeline started...")

    for {
        msg, err := r.ReadMessage(ctx)
        if err != nil {
            log.Println("Error reading Kafka message:", err)
            continue
        }

        var records []TelemetryRecord
        if err := json.Unmarshal(msg.Value, &records); err != nil {
            log.Println("Failed to unmarshal JSON:", err)
            continue
        }

        for _, rec := range records {
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
                log.Println("Cassandra insert error:", err)
            }
        }

        log.Printf("Processed %d records\n", len(records))
    }
}
