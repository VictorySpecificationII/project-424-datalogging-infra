# Kafka and Spark Streaming Tutorial

## Overview

In this tutorial, you'll learn how to consume messages from Kafka using Apache Spark, process them, and output the results. We'll use PySpark (the Python API for Spark) and Kafka as the messaging system.

## Prerequisites

- **Kafka**: A running Kafka broker.
- **Spark**: A Spark cluster (with a master and worker node).
- **Zookeeper**: Required by Kafka for coordination.
- **Python Libraries**: 
  - `pyspark`
  - `kafka-python`

## 1. Setup Prerequisites

### 1.1 Required Containers

Ensure you have the following Docker containers running:

- **Kafka** (`ubuntu/kafka`)
- **Spark Master** (`bitnami/spark`)
- **Spark Worker** (`bitnami/spark`)
- **Zookeeper** (`ubuntu/zookeeper`)

### 1.2 Install Required Libraries

Install the required Python libraries:

```bash
pip install pyspark kafka-python
```

## 2. Writing Kafka Producer (Sending Messages to Kafka)

Create a Python script named kafka_prod.py that will send messages to a Kafka topic.

## 3. Writing Spark Streaming Application (Processing Kafka Messages)

Create a Python script named spark.py that will consume messages from the Kafka topic and process them using Spark.

## 4. Running the Spark Streaming Application

### 4.1 Start Kafka Producer

Run the kafka_prod.py script to start sending messages to Kafka:

```bash
python3 kafka_prod.py
```
This script will send 100 messages to the test-topic Kafka topic.

### 4.2 Start Spark Streaming Job

Exec into the spark-master container, and run the spark.py script to start consuming and processing the messages in Spark:

Dependencies already in /jar file

```bash
spark-submit --master spark://spark-master:7077 spark.py
```

Dependencies explicitly mentioned if not in jar
```bash
spark-submit --master spark://spark-master:7077 --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.2 spark.py
```

Experimental, running in local mode with explicitly mentioned dependencies

```bash
spark-submit \
  --master local[*] \
  --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.2,org.apache.kafka:kafka-clients:3.4.1 \
  spark.py
```

## 5. What’s Happening?

    Kafka Producer:
        Sends 100 JSON messages to the test-topic.
        Each message contains a message_number and message_content.

    Spark Streaming Application:
        Connects to the Kafka topic test-topic.
        Reads and parses the incoming JSON messages.
        Filters messages to include only those with even message_number.
        Outputs the filtered messages to the console.

## 6. Monitoring and Debugging

    Kafka UI: Access the Kafka UI to monitor the messages being produced.
    Spark UI: Access the Spark UI to monitor the job execution and see how the streaming job is running.

## 7. Next Steps

    Enhancing Processing Logic: You can add more complex processing like aggregations, joins, or machine learning models using Spark’s APIs.
    Output to Other Sinks: Instead of printing to the console, output the processed data to storage systems like HDFS, databases, or another Kafka topic.

This tutorial provides a basic introduction to using Kafka and Spark together. As you get more comfortable, you can experiment with more advanced features like windowed aggregations, stateful processing, and integration with other data sources.