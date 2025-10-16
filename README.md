
# Project 424 Telemetry Logging Infrastructure

This project implements a near real-time telemetry logging pipeline for the PERRINN 424 EV using Unity, Kafka, a Go consumer, and Cassandra. It collects telemetry data from the Unity simulation, streams it via Kafka, processes it with a Go consumer, and stores it in Cassandra for further analysis.

---

## Architecture

```
Unity (Telemetry Module) --> Kafka (Message Broker) --> Go Consumer --> Cassandra (Storage)
```

- **Unity Module**: Captures telemetry data from the vehicle simulation and publishes it to Kafka as JSON batches.
- **Kafka**: Message broker to buffer and stream telemetry messages.
- **Go Consumer**: Reads telemetry messages from Kafka, parses JSON, and writes records into Cassandra.
- **Cassandra**: Database that stores the telemetry records.

Flink services are included in the Docker stack but not currently used. If you know how to write jobs for it, it's there for you.

---

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
   - Contains Docker setup for Kafka, Cassandra, Go consumer, and optional Flink services.

---

## Docker Setup

Included `docker-compose.yaml` spins up:

- **Kafka Broker** (`broker`)
- **Kafka UI** (`kafka-ui`)
- **Cassandra** (`cassandra`) with initial schema
- **Go Consumer** (`go-consumer`)
- **Flink JobManager/TaskManager** (not currently used)

### Volumes

- `cassandra-data`: Persistent Cassandra storage
- `cassandra-init`: Contains the initial schema (`schema.cql`)

Once the stack is deployed, you need to run the following commands inside the cassandra container to prime it:

```
docker exec -it cassandra /bin/bash
cqlsh
SOURCE '/docker-entrypoint-initdb.d/schema.cql';
DESCRIBE KEYSPACES;
USE telemetry;
DESCRIBE TABLES;
```

---

## Running the Pipeline

1. Clone the **infrastructure repo**:

```bash
git clone https://github.com/VictorySpecificationII/project-424-datalogging-infra.git
cd project-424-datalogging-infra/docker
```

2. Start services via Docker:

```bash
docker-compose up -d -- build
```

3. Clone the **Unity project fork**:

```bash
git clone https://github.com/VictorySpecificationII/project-424-unity.git
```

4. Open the Unity project, the KafkaTelemetry2 component is attached to your vehicle, and enabled for telemetry.

5. Unity will start sending telemetry batches to Kafka, which the Go consumer will store in Cassandra automatically.

6. Kafka UI can be accessed at [http://localhost:8080](http://localhost:8080) to monitor topics.

---

## Notes

- Kafka topic name is dynamically generated per session in Unity:
  ```
  p424-telemetry-batch-<YYYYMMDD-HHmmss>
  ```
- Flink services are included but not wired to any pipeline yet.
- Go consumer has pre-flight checks for Kafka and Cassandra connectivity.
- As of now you have to manually insert the name of the kafka topic in the go exporter, I will fix it in the future.