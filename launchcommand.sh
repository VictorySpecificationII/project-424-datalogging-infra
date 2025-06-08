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
sed -i "s/\(advertised.listeners=PLAINTEXT:\/\/\)[^:]*\(:9092\)/\1${machine_ip}\2/" "$PWD/$kafka_server_properties_file"

echo "PreBoot: Updated kafka-server.properties file with machine's IP address: $machine_ip"

docker-compose --env-file toolchain-config.env up -d --build

echo "PostBoot: Stack is operational."
