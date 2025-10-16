package com.project424.flink;

import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.cassandra.CassandraSink;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaConsumer;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import java.util.Properties;

public class TelemetryJob {

    public static void main(String[] args) throws Exception {
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // Kafka properties
        Properties props = new Properties();
        props.setProperty("bootstrap.servers", "broker:29092");
        props.setProperty("group.id", "telemetry-consumer");

        // Dynamic topic example (replace with actual logic if needed)
        String topic = "p424-telemetry-batch";

        FlinkKafkaConsumer<String> consumer =
                new FlinkKafkaConsumer<>(topic, new SimpleStringSchema(), props);

        consumer.setStartFromLatest();

        ObjectMapper objectMapper = new ObjectMapper();

        env
            .addSource(consumer)
            .flatMap((String value, org.apache.flink.util.Collector<TelemetryRecord> out) -> {
                List<TelemetryRecord> records = objectMapper.readValue(
                        value,
                        objectMapper.getTypeFactory().constructCollectionType(List.class, TelemetryRecord.class)
                );
                for (TelemetryRecord r : records) {
                    out.collect(r);
                }
            })
            .returns(TelemetryRecord.class)
            .addSink(
                CassandraSink.addSink(env.fromElements())
                        .setHost("cassandra")
                        .build()
            );

        env.execute("Telemetry Kafka to Cassandra Job");
    }
}

