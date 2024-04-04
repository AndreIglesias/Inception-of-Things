#!/usr/bin/env bash

# Function to install k3s master
install_k3s_master() {
    echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/vagrant/.profile
    curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE=644 k3S_CLUSTER_INIT=1 INSTALL_K3S_EXEC='--flannel-iface=eth1' sh -
}

# Function to copy token to /vagrant
copy_token_to_vagrant() {
    sudo cp /var/lib/rancher/k3s/server/token /vagrant/
    sudo chown vagrant:vagrant /vagrant/token
}

# Function to install kubectl
install_kubectl() {
    # Download the kubectl binary
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

    # Verify the kubectl binary against the checksum
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

    # Install kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

# Main script
main() {
    install_k3s_master
    copy_token_to_vagrant
    install_kubectl
}

main
