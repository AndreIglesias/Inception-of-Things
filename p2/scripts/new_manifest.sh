#!/usr/bin/env bash

new_deployment() {
    local APP=$1
    local REPLICAS=$2

    cat << EOF | sudo tee -a /vagrant/confs/manifest.yaml > /dev/null
# Deployments for $APP
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-$APP  # Name of the deployment
  labels:
    app: deploy-$APP  # Label for the deployment
spec:
  replicas: $REPLICAS  # Number of replicas
  selector:
    matchLabels:
      app: $APP  # Label selector for pods
  template:
    metadata:
      labels:
        app: $APP  # Label for pods
    spec:
      containers:
      - name: hello-kubernetes
        image: paulbouwer/hello-kubernetes:1.9
        env:
          - name: MESSAGE
            value: "Hello from $APP."
        ports:
        - hostPort: 8888
          containerPort: 8080

EOF
}

new_service() {
    local APP=$1

    cat << EOF | sudo tee -a /vagrant/confs/manifest.yaml > /dev/null
apiVersion: v1
kind: Service
metadata:
  name: svc-$APP  # Name of the service
spec:
  selector:
    app: $APP  # Label selector for pods
  ports:
    - protocol: TCP  # Protocol for the port
      port: 8880  # Port exposed by the service
      targetPort: 8888  # Port on the pods

EOF
}

main() {
    # Remove the existing manifest file
    sudo rm -f /vagrant/confs/manifest.yaml

    new_deployment "app1" 1
    new_deployment "app2" 3
    new_deployment "app3" 1

    new_service "app1"
    new_service "app2"
    new_service "app3"

    kubectl apply -f /vagrant/confs/manifest.yaml
    kubectl apply -f /vagrant/confs/ingress.yaml
}

main