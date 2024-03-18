#!/usr/bin/env bash

while [ ! -f /vagrant/token ]; do
    echo "Waiting for token..."
    sleep 5
done

TOKEN=$(cat /vagrant/token)
IPMaster="192.168.56.110"
curl -sfL https://get.k3s.io | K3S_URL="https://${IPMaster}:6443" K3S_TOKEN=$TOKEN INSTALL_K3S_EXEC='--flannel-iface=eth1' sh -
rm /vagrant/token
