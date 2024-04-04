#!/bin/env bash

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

    # Port forward the ArgoCD server
    echo -e "\n🚀 Port forwarding the ArgoCD server..."
    # sudo kubectl port-forward svc/argocd-server -n argocd 8443:443
    sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8443:443
}

# Main script
main() {
    create_namespaces
    install_argocd
}

main
