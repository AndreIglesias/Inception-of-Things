#!/usr/bin/env bash

# Update hosts file on the local machine
update_hosts() {
    ip_address="$1"
    shift
    hostnames=("$@")

    # Remove existing entries for the specified hostnames
    for hostname in "${hostnames[@]}"; do
        sudo sed -i "/$hostname/d" /etc/hosts
    done

    # Add new entries for the specified hostnames
    for hostname in "${hostnames[@]}"; do
        echo "$ip_address $hostname" | sudo tee -a /etc/hosts > /dev/null
    done
}

# Update hosts file with K3s master IP and application hostnames
update_hosts "$1" "${@:2}"

echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/vagrant/.profile
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE=644 k3S_CLUSTER_INIT=1 INSTALL_K3S_EXEC='--flannel-iface=eth1' sh -

sudo cp /var/lib/rancher/k3s/server/token /vagrant/
sudo chown vagrant:vagrant /vagrant/token

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
