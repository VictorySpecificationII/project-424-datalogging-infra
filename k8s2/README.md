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
```

Then, depending on whether you're running Microk8s or K3/8s, modify the `deploy.sh` file and run:

```
chmod +x deploy.sh
./deploy.sh
```
