using System;
using Confluent.Kafka;

class Program
{
    static void Main(string[] args)
    {
        var config = new ConsumerConfig
        {
            BootstrapServers = "localhost:9092", // or "broker:29092" in Docker
            GroupId = "test-group",
            AutoOffsetReset = AutoOffsetReset.Earliest
        };

        using var consumer = new ConsumerBuilder<Ignore, string>(config).Build();

        string topicName = "my-topic";
        consumer.Subscribe(topicName);

        Console.WriteLine($"Subscribed to topic {topicName}. Waiting for messages...");

        try
        {
            while (true)
            {
                var consumeResult = consumer.Consume();
                Console.WriteLine($"Received: {consumeResult.Message.Value} at {consumeResult.TopicPartitionOffset}");
            }
        }
        catch (OperationCanceledException)
        {
            consumer.Close();
        }
    }
}
