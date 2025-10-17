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


## Deployment Validation

Follow the steps below in order, to validate the stack.

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


For the connectors, you can copy any JARs to the named volume using this command:

```
docker cp /full/path/to/your-connector.jar connect:/etc/kafka-connect/jars/
```

### Example
Link to a connector for testing: `https://mvnrepository.com/artifact/org.apache.kafka/connect-file/4.1.0`
Command to copy to the container: `docker cp connect-file-4.1.0.jar connect:/etc/kafka-connect/jars/`
Command to restart the container: `docker-compose restart connect`
Command to test if the connector is loaded: `curl http://localhost:8083/connector-plugins`

It should give you this output:

```
[{"class":"org.apache.kafka.connect.file.FileStreamSinkConnector","type":"sink","version":"8.1.0-ccs"},{"class":"org.apache.kafka.connect.file.FileStreamSourceConnector","type":"source","version":"8.1.0-ccs"},{"class":"org.apache.kafka.connect.mirror.MirrorCheckpointConnector","type":"source","version":"8.1.0-ccs"},{"class":"org.apache.kafka.connect.mirror.MirrorHeartbeatConnector","type":"source","version":"8.1.0-ccs"},{"class":"org.apache.kafka.connect.mirror.MirrorSourceConnector","type":"source","version":"8.1.0-ccs"}]`
```

The connector is loaded.

Now you create a test connector based on the connector jar we imported:

```
curl -X POST -H "Content-Type: application/json" \
  --data '{
    "name": "test-sink",
    "config": {
      "connector.class": "org.apache.kafka.connect.file.FileStreamSinkConnector",
      "tasks.max": "1",
      "file": "/tmp/output.txt",
      "topics": "my-topic"
    }
  }' \
  http://localhost:8083/connectors
```
Should give an output that looks like this:

```
{"name":"test-sink","config":{"connector.class":"org.apache.kafka.connect.file.FileStreamSinkConnector","tasks.max":"1","file":"/tmp/output.txt","topics":"my-topic","name":"test-sink"},"tasks":[],"type":"sink"}
```

Check connector status with

```
curl http://localhost:8083/connectors/test-sink/status | jq
```

Check connector config with

```
curl http://localhost:8083/connectors/test-sink/config | jq
```

You have created a topic named "my-topic" in Kafka and have some messages in it. If you haven't, check the section Kafka above.

Publish a message via REST Proxy:

```
curl -X POST -H "Content-Type: application/vnd.kafka.json.v2+json" \
  --data '{
    "records":[{"value":{"foo":"bar"}}]
  }' \
  http://localhost:8082/topics/my-topic

```

Any messages you publish to that topic, will appear in the `/tmp/output.txt` file inside the container for this test.

You can check with:

```
docker exec -it connect cat /tmp/output.txt
``` 

## Flink

Navigate to `localhost:8087` to see the UI, the task manager is already bound to the job manager for you.

## Cassandra

Run the following commands to verify it works:

```
docker exec -it cassandra /bin/bash
cqlsh
SOURCE '/docker-entrypoint-initdb.d/schema.cql';
DESCRIBE KEYSPACES;
USE telemetry;
DESCRIBE TABLES;
```