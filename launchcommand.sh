#/!bin/bash

# Get the machine's IP address
machine_ip=$(hostname -I | cut -d' ' -f1)

# Path to the kafka-server.properties file
kafka_server_properties_file="kafka-server.properties"

# Update the advertised.listeners property with the machine's IP address
sed -i "s/advertised.listeners=PLAINTEXT:\/\/localhost:9092/advertised.listeners=PLAINTEXT:\/\/${machine_ip}:9092/" "$PWD/$kafka_server_properties_file"

echo "Updated kafka-server.properties file with machine's IP address: $machine_ip"

docker-compose --env-file toolchain-config.env up -d --build
