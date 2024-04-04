#!/bin/env bash

# Update system and install prerequisites
install_prerequisites() {
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update && sudo apt-get install -y curl
}

# Install Docker
install_docker() {
    curl -fsSL https://get.docker.com | sh
}

# Install kubectl
install_kubectl() {
    # Download the kubectl binary
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

    # Verify the kubectl binary against the checksum
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

    # Install kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

# Install k3d
install_k3d() {
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    sudo k3d cluster create ciglesiaS # Testing
}

# Execute main script
main() {
    install_prerequisites
    install_docker
    install_kubectl
    install_k3d
}

main
