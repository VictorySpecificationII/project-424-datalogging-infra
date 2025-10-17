
# Project 424 Telemetry Logging Infrastructure

This project implements a near real-time telemetry logging pipeline for the PERRINN 424 EV using Unity and an Apache stack. It collects telemetry data from the Unity simulation, streams it via Kafka, processes it via the Apache stack, and stores it in Cassandra for further analysis.

## Usage

Before running the telemetry pipeline, you need the following:

1. **Unity Project with Kafka Telemetry Module**  
   - GitHub: [project-424-unity](https://github.com/VictorySpecificationII/project-424-unity)  
   - The `KafkaTelemetry2` module is located at:  
     ```
     project-424-unity/Assets/Features/Telemetry RT Streaming/KafkaTelemetry2.cs
     ```
   - Currently, the module is only available in this fork until a pull request is merged into the main project.

2. **Telemetry Logging Infrastructure**  
   - GitHub: [project-424-datalogging-infra](https://github.com/VictorySpecificationII/project-424-datalogging-infra)  
   - Contains the entire stack required for analysis.


Once you have downloaded both stacks:

1. **Unity Simulation Preparation**
   - Once you've downloaded the Unity Simulation, go into the directory in step 1, and modify the localhost:9092 entry with the IP of the machine you are running on.
   - Or, if you're running both on the same machine, there's no need for modifications.
   - Ensure that the `Emit Telemetry` checkbox is ticked.

2. **Telemetry Logging Infrastructure**
   - Run `docker-compose up -d`


Once you enter Unity and hit play, it will automatically start sending data to the Kafka instance. You'll be able to see them in the Kafka UI. You can then go ahead and write
Flink jobs to grab from Kafka, transform, and send to Cassandra.

