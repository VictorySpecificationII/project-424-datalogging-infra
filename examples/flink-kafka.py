from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import StreamTableEnvironment
from pyflink.table.descriptors import Schema, Kafka
# Create Flink environment
env = StreamExecutionEnvironment.get_execution_environment()
t_env = StreamTableEnvironment.create(env)
# Define Kafka source
t_env.connect(
    Kafka()
    .version("universal")
    .topic("input_topic")
    .start_from_latest()
    .property("bootstrap.servers", "localhost:9092")
).with_format(
    Json()
).with_schema(
    Schema().field("field1", "STRING").field("field2", "INT")
).create_temporary_table("kafka_source")
# Define processing logic
result = t_env.from_path("kafka_source").select("field1, field2 + 1")
# Write the result to a Kafka sink
result.execute_insert("output_topic")
# Execute Flink job
env.execute("Python Flink Job")
