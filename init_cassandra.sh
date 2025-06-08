#!/bin/bash
set -e

DOCKER_CQLSH="docker exec -i cassandra cqlsh -u cassandra -p cassandra"
KEYSPACE="telemetry"

echo "[init_cassandra.sh] Waiting for Cassandra to be available..."
until $DOCKER_CQLSH -e "describe keyspaces"; do
  echo "Cassandra is unavailable - sleeping"
  sleep 3
done

echo "[init_cassandra.sh] Cassandra is up. Checking if keyspace '$KEYSPACE' exists..."

EXISTS=$($DOCKER_CQLSH -e "describe keyspace $KEYSPACE" 2>/dev/null || echo "NO")

if [[ "$EXISTS" == "NO" ]]; then
  echo "Keyspace $KEYSPACE does not exist. Creating schema..."

  # Use a heredoc to feed CQL commands to cqlsh inside the container
  $DOCKER_CQLSH <<EOF
CREATE KEYSPACE $KEYSPACE WITH replication = {'class':'SimpleStrategy', 'replication_factor':3};
USE $KEYSPACE;
CREATE TABLE vehicle_telemetry (
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

  echo "Schema created successfully."
else
  echo "Keyspace $KEYSPACE already exists. Skipping schema creation."
fi

exec "$@"
