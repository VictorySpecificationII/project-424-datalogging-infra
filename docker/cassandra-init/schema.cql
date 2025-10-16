-- Create a keyspace for your telemetry data
CREATE KEYSPACE IF NOT EXISTS telemetry
WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor': 1 };

-- Switch to that keyspace
USE telemetry;

-- Create your table in that keyspace
CREATE TABLE IF NOT EXISTS telemetry_full (
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