#!/bin/env bash

port_forward_service() {
    local PORT=$1
    local FORWD=$2
    local NS=$3
    local SVC=$4

    # Create the systemd unit file
    cat <<EOF | sudo tee /etc/systemd/system/port-forward-$PORT.service > /dev/null
[Unit]
Description=Port Forwarding for Port $PORT
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do if ! nc -z localhost $PORT; then sudo kubectl port-forward --address 0.0.0.0 svc/$SVC -n $NS $PORT:$FORWD; fi; sleep 1; done'

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd
    sudo systemctl daemon-reload

    # Enable and start the service
    sudo systemctl enable port-forward-$PORT.service
    sudo systemctl start port-forward-$PORT.service

    # Check status
    sudo systemctl status port-forward-$PORT.service
}

# Function to create namespaces
create_namespaces() {
    # Setup namespaces argocd and dev
    sudo kubectl create namespace argocd
    sudo kubectl create namespace dev
}

# Function to install ArgoCD
install_argocd() {
    # The manifest was downloaded from the official ArgoCD GitHub repository
    # With the command (slow download):
    # curl -sSL -o /vagrant/confs/argocd.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    # Install ArgoCD
    echo "✨ Installing ArgoCD..."
    sudo kubectl apply -n argocd -f /vagrant/confs/argocd.yaml

    sleep 5
    # To verify the installation:
    echo "🔍 Verifying the installation..."
    # sudo watch kubectl get pods -n argocd
    sudo kubectl get pods -n argocd

    # Wait for all pods to be ready
    echo "⏱️ Waiting for all pods to be ready..."
    sudo kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd
    sudo kubectl get pods -n argocd

    # Get the password
    echo "🔑 Getting the ArgoCD password..."
    sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    echo -e "\nUsername: admin"

    # Port forward the ArgoCD server
    echo -e "\n🚀 Port forwarding the ArgoCD server..."
    # sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8443:443 &
    port_forward_service 8443 443 argocd argocd-server
    echo -e "\n🔗 Access the ArgoCD dashboard at https://localhost:8443"
}

deploy_app() {
    # deploy the app
    echo -e "\n✨ Deploying the app..."
    sudo kubectl apply -f /vagrant/confs/deploy-app.yaml
    sleep 5
    sudo kubectl get pods -n dev
    # Wait for all pods to be ready
    echo "⏱️ Waiting for all pods to be ready..."
    sudo kubectl wait --for=condition=ready --timeout=600s pod --all -n dev
    sudo kubectl get pods -n dev

    # Port forward the app
    echo -e "\n🚀 Port forwarding the app..."
    # sudo kubectl port-forward --address 0.0.0.0 svc/svc-wil-playground -n dev 8888:8080 &
    port_forward_service 8888 8080 dev svc-wil-playground
    echo -e "\n🌐 Access the app at http://localhost:8888"
}

# Main script
main() {
    create_namespaces
    install_argocd
    deploy_app
}

main
