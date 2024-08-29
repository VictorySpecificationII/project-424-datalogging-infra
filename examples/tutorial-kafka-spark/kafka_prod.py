from kafka import KafkaProducer
import json
import time

# Kafka configuration
kafka_topic = 'test-topic'
kafka_broker = '192.168.10.72:9092'  # Replace with your Kafka broker

# Create Kafka producer
producer = KafkaProducer(
    bootstrap_servers=kafka_broker,
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

# Send messages to Kafka
for i in range(100):
    message = {'message_number': i, 'message_content': f'This is message {i}'}
    producer.send(kafka_topic, message)
    print(f'Sent: {message}')
    time.sleep(1)

producer.flush()
producer.close()
