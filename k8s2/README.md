# perrinn-424-datalogging-infra

## Prerequisites:

 - Microk8s/K3s/K8s
 - hostpath-storage
 - nginx-ingress

## Deployment

In your localhost `/etc/hosts` file, add:

```
127.0.0.1 kafka-ui.local
127.0.0.1 zoonavigator-ui.local
127.0.0.1 kafka-rest-proxy.local
```

Then, depending on whether you're running Microk8s or K3/8s, modify the `deploy.sh` file and run:

```
chmod +x deploy.sh
./deploy.sh
```

##

# 1. List topics
curl -s http://kafka-rest-proxy.local/topics

# 2. Produce a test message
curl -X POST -H "Content-Type: application/vnd.kafka.json.v2+json" -d '{"records":[{"value":{"msg":"hello world"}}]}' http://kafka-rest-proxy.local/topics/test-event

# 3. Create a consumer instance
curl -X POST -H "Content-Type: application/vnd.kafka.json.v2+json" -d '{"name":"my-consumer-instance","format":"json","auto.offset.reset":"earliest"}' http://kafka-rest-proxy.local/consumers/my-group

# 4. Subscribe the consumer to the topic
curl -X POST -H "Content-Type: application/vnd.kafka.json.v2+json" -d '{"topics":["test-event"]}' http://kafka-rest-proxy.local/consumers/my-group/instances/my-consumer-instance/subscription

# 5. Consume messages
curl -X GET -H "Accept: application/vnd.kafka.json.v2+json" http://kafka-rest-proxy.local/consumers/my-group/instances/my-consumer-instance/records

