# Service Map

localhost:9092 - Kafka Broker
localhost:8080 - Kafka UI
localhost:8081 - Flink UI


# Useful Commands for Experimentation

## Kafka
```
docker compose up -d
docker logs -f broker
docker exec -it -w /opt/kafka/bin broker sh
```
### Create a topic
```
./kafka-topics.sh --create --topic my-topic --bootstrap-server broker:29092
```
### Start a producer and send messages
```
./kafka-console-producer.sh  --topic my-topic --bootstrap-server broker:29092
```
### Start a consumer and consume messages
```
./kafka-console-consumer.sh --topic my-topic --from-beginning --bootstrap-server broker:29092
```
### Shut it down
```
docker compose down -v
```

### Important
Take note of the `--bootstrap-server` flag. Because you're connecting to Kafka inside the container, you use `broker:29092` for the host:port. 
If you were to use a client outside the container to connect to Kafka, a producer application running on your laptop for example, you'd use `localhost:9092` instead.
