from kafka import KafkaProducer
from kafka.errors import KafkaError

def check_kafka_producer_connection(broker_url, topic='test-topic'):
    producer = None
    try:
        # Initialize Kafka producer
        producer = KafkaProducer(bootstrap_servers=broker_url)
        
        # Send a test message to the specified topic
        future = producer.send(topic, b'Test message')
        
        # Block until a single message is sent (or timeout)
        result = future.get(timeout=10)
        
        print("Test message sent successfully!")
        
    except KafkaError as e:
        print(f"Failed to connect to Kafka or send message: {e}")
    finally:
        # Close the producer if it was initialized
        if producer:
            producer.close()

if __name__ == "__main__":
    # Replace with your Kafka broker URL
    broker_url = '10.144.0.2:9092'
    # Optionally, replace with a specific topic you want to check
    topic = 'test-topic'
    
    check_kafka_producer_connection(broker_url, topic)
