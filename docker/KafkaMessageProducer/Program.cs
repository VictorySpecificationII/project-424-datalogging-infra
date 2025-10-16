using System;
using System.Threading.Tasks;
using Confluent.Kafka;

class Program
{
    static async Task Main(string[] args)
    {
        var config = new ProducerConfig
        {
            BootstrapServers = "localhost:9092" // or "broker:29092" if running inside Docker network
        };

        using var producer = new ProducerBuilder<Null, string>(config).Build();

        string topicName = "my-topic";
        string message = "Hello Kafka from C#!";

        try
        {
            var deliveryResult = await producer.ProduceAsync(topicName, new Message<Null, string> { Value = message });
            Console.WriteLine($"Message sent to {deliveryResult.TopicPartitionOffset}");
        }
        catch (ProduceException<Null, string> e)
        {
            Console.WriteLine($"Error producing message: {e.Error.Reason}");
        }
    }
}

