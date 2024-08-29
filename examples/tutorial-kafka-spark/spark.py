# from pyspark.sql import SparkSession
# from pyspark.sql.functions import from_json, col
# from pyspark.sql.types import StructType, StructField, StringType, IntegerType

# # Kafka and Spark configuration
# kafka_topic = 'test-topic'
# kafka_broker = 'kafka:9092'  # Replace with your Kafka broker

# # Define schema of the incoming data
# schema = StructType([
#     StructField("message_number", IntegerType(), True),
#     StructField("message_content", StringType(), True)
# ])

# # Create Spark session
# spark = SparkSession.builder \
#     .appName("KafkaSparkStreaming") \
#     .master("spark://spark-master:7077") \
#     .getOrCreate()

# # Read data from Kafka
# df = spark.readStream \
#     .format("kafka") \
#     .option("kafka.bootstrap.servers", kafka_broker) \
#     .option("subscribe", kafka_topic) \
#     .load()

# # Convert the value column from bytes to string
# df = df.selectExpr("CAST(value AS STRING)")

# # Parse the JSON messages
# json_df = df.select(from_json(col("value"), schema).alias("data")).select("data.*")

# # Perform some processing (e.g., filter messages)
# processed_df = json_df.filter(col("message_number") % 2 == 0)

# # Write the processed data to the console (for demonstration purposes)
# query = processed_df.writeStream \
#     .outputMode("append") \
#     .format("console") \
#     .start()

# query.awaitTermination()

from pyspark.sql import SparkSession
from pyspark.sql.streaming import *

spark = SparkSession \
    .builder \
    .appName("Spark Kafka Streaming") \
    .master("spark://spark-master:7077") \
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0") \
    .getOrCreate()

# spark.sparkContext.setLogLevel("ERROR")

df = spark \
    .readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "kafka:9092") \
    .option("subscribe", "test-topic") \
    .option("startingOffsets", "earliest") \
    .load()

df.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")

query = df \
    .writeStream \
    .outputMode("update") \
    .format("console") \
    .start()

# raw = spark.sql("select * from `kafka-streaming-messages`")
# raw.show()

query.awaitTermination()