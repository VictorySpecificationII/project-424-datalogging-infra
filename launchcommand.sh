#/!bin/bash

echo "=================================================================="
echo "=  ____  _____ ____  ____  ___ _   _ _   _   _  _  ____  _  _    ="
echo "= |  _ \| ____|  _ \|  _ \|_ _| \ | | \ | | | || ||___ \| || |   ="
echo "= | |_) |  _| | |_) | |_) || ||  \| |  \| | | || |_ __) | || |_  ="
echo "= |  __/| |___|  _ <|  _ < | || |\  | |\  | |__   _/ __/|__   _| ="
echo "= |_|   |_____|_| \_\_| \_\___|_| \_|_| \_|    |_||_____|  |_|   ="
echo "=                                                                ="
echo "=================================================================="
echo "         Telemetry Streaming and Data Acquisition System          "
echo "                                                                  "
echo "                                                                  "
# Get the machine's IP address
machine_ip=$(hostname -I | cut -d' ' -f1)

# Path to the kafka-server.properties file
kafka_server_properties_file="kafka-server.properties"

# Update the advertised.listeners property with the machine's IP address
sed -i "s/advertised.listeners=PLAINTEXT:\/\/localhost:9092/advertised.listeners=PLAINTEXT:\/\/${machine_ip}:9092/" "$PWD/$kafka_server_properties_file"

echo "Boot: Updated kafka-server.properties file with machine's IP address: $machine_ip"

docker-compose --env-file toolchain-config.env up -d --build

# Obtain the IPv4 address of the Docker container
ipv4_address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mlflow_db)

# Replace the "Host" value in the JSON file with the obtained IPv4 address
jq --arg ipv4 "$ipv4_address" '.Servers."1".Host = $ipv4' pgadmin4_psql_servers.json > tmp_pgadmin4_psql_servers.json

# Replace the original file with the updated one
mv tmp_pgadmin4_psql_servers.json pgadmin4_psql_servers.json

echo "Boot: Updated pgadmin4_psql_servers.json file with mlflow_db container's IP address: $ipv4_address"

docker stop pgadmin4

docker rm pgadmin4

docker-compose --env-file toolchain-config.env up -d pgadmin4
