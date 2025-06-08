#!/bin/bash
set -e

docker exec -i cassandra cqlsh -u cassandra -p cassandra <<EOF
CREATE KEYSPACE IF NOT EXISTS telemetry WITH replication = {'class':'SimpleStrategy', 'replication_factor':3};
USE telemetry;
CREATE TABLE IF NOT EXISTS vehicle_telemetry (
  vehicle_id text,
  session_id text,
  channel_id int,
  timestamp timestamp,
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
  PRIMARY KEY ((vehicle_id, session_id, channel_id), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);
EOF
