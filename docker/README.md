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


## REST Proxy

Create a topic named "my-topic" in Kafka via the UI.

Then run, to test:

```
curl -X POST -H "Content-Type: application/vnd.kafka.json.v2+json" \
  --data '{"records":[{"value":{"foo":"bar"}}]}' \
  http://localhost:8082/topics/my-topic
```

Should give you something like:

```
{"offsets":[{"partition":0,"offset":1,"error_code":null,"error":null}],"key_schema_id":null,"value_schema_id":null}
```

That means success.

## Schema Registry

Run, to test:

```
curl http://localhost:8281/subjects
```

Should come up empty, since it's a fresh installation.

## Kafka Connect

Run, to test:

```
curl http://localhost:8083/
```

You should get a response including commit number, you see that, it means it's reachable.

```
curl http://localhost:8083/connectors
```

You should get an `[]` response, since it's empty


