#/!bin/bash

# Get the machine's IP address
machine_ip=$(hostname -I | cut -d' ' -f1)

# Path to the server.properties file
server_properties_file="server.properties"

# Update the advertised.listeners property with the machine's IP address
sed -i "s/advertised.listeners=PLAINTEXT:\/\/localhost:9092/advertised.listeners=PLAINTEXT:\/\/${machine_ip}:9092/" "$PWD/$server_properties_file"

echo "Updated server.properties file with machine's IP address: $machine_ip"

docker-compose --env-file config.env up -d --build
