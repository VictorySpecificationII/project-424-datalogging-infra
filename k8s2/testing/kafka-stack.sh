#!/bin/bash
curl -s http://kafka-rest.local/topics | jq
curl -X POST   -H "Content-Type: application/vnd.kafka.v2+json"   --data '{
    "name": "my-consumer",
    "format": "json",
    "auto.offset.reset": "earliest"
  }'   http://kafka-rest.local/consumers/my-group | jq
curl -X POST   -H "Content-Type: application/vnd.kafka.v2+json"   --data '{
    "topics":["test-event"]
  }'   http://kafka-rest.local/consumers/my-group/instances/my-consumer/subscription | jq
curl -X POST   -H "Content-Type: application/vnd.kafka.json.v2+json"   -H "Accept: application/vnd.kafka.v2+json"   --data '{
    "records":[{"value":{"hello":"world"}}]
  }'   http://kafka-rest.local/topics/test-event | jq
curl -X GET   -H "Accept: application/vnd.kafka.json.v2+json"   "http://kafka-rest.local/consumers/my-group/instances/my-consumer/records?timeout=5000" | jq
