
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
