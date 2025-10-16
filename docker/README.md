## C# Program

```
sudo snap install dotnet --classic
dotnet
dotnet new console -n KafkaTopicCreator
cd KafkaTopicCreator
dotnet add package Confluent.Kafka
dotnet run
```

# Launch
```
docker compose up -d
docker logs -f broker
docker exec -it -w /opt/kafka/bin broker sh
```
## Create a topic
```
./kafka-topics.sh --create --topic my-topic --bootstrap-server broker:29092
```
## Start a producer and send messages
```
./kafka-console-producer.sh  --topic my-topic --bootstrap-server broker:29092
```
## Start a consumer and consume messages
```
./kafka-console-consumer.sh --topic my-topic --from-beginning --bootstrap-server broker:29092
```
## Shut it down
```
docker compose down -v
```

# Important
Take note of the `--bootstrap-server` flag. Because you're connecting to Kafka inside the container, you use `broker:29092` for the host:port. 
If you were to use a client outside the container to connect to Kafka, a producer application running on your laptop for example, you'd use `localhost:9092` instead.

## Service Map

localhost:9092 - Kafka Broker
localhost:8080 - Kafka UI
localhost:8081 - Flink UI


# Flink Job Prerequisites

## Scala Installation

```
curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && chmod +x cs && ./cs setup
```

To build a job, run:

```
sbt package
```

Then follow the instructions. Once done, log out/reboot, and run `scala --version` to verify.

## SBT Installation

```
sudo apt-get update
sudo apt-get install apt-transport-https curl gnupg -yqq
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
sudo apt-get update
sudo apt-get install sbt
```
## JVM Installation

```
sudo apt-get install openjdk-21-jdk
```



## Cassandra

Modify the `.cqlsh` file in `cassandra-init` to establish your table. It will automatically load in Cassandra.

```
docker exec -it cassandra /bin/bash
cqlsh
SOURCE '/docker-entrypoint-initdb.d/schema.cql';
DESCRIBE KEYSPACES;
USE telemetry;
DESCRIBE TABLES;
```

Table should show.

## Maven build

```
sudo apt-get install maven
```
