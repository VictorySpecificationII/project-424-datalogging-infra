using System;
using System.Threading.Tasks;
using Confluent.Kafka;
using Confluent.Kafka.Admin;

class Program
{
    static async Task Main(string[] args)
    {
        var config = new AdminClientConfig
        {
            BootstrapServers = "localhost:9092" // or "broker:29092" if running inside Docker network
        };

        using var adminClient = new AdminClientBuilder(config).Build();

        string topicName = "my-topic";

        var topicSpecification = new TopicSpecification
        {
            Name = topicName,
            NumPartitions = 1,
            ReplicationFactor = 1
        };

        try
        {
            await adminClient.CreateTopicsAsync(new[] { topicSpecification });
            Console.WriteLine($"Topic '{topicName}' created successfully!");
        }
        catch (CreateTopicsException e)
        {
            // Topic already exists
            if (e.Results[0].Error.Code == ErrorCode.TopicAlreadyExists)
            {
                Console.WriteLine($"Topic '{topicName}' already exists.");
            }
            else
            {
                Console.WriteLine($"An error occurred creating topic: {e.Results[0].Error.Reason}");
            }
        }
    }
}

