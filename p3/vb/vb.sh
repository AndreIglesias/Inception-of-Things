#!/bin/bash

# Set up VM properties
VM_NAME="p3"

# Parent directory
PARENT_DIR=$(dirname "$PWD")

# .vbox file
VBOX_FILE="p3.vbox"

# Create backup for .vbox
if [ -f "$VBOX_FILE" ]; then
    cp "$VBOX_FILE" "$VBOX_FILE.bkp"
fi

# Create VM
VBoxManage registervm "$VBOX_FILE"

# Mount current directory as /vagrant in the VM
VBoxManage sharedfolder add "$VM_NAME" --name "vagrant" --hostpath "$PARENT_DIR" 

# Start VM
VBoxManage startvm "$VM_NAME"

# Inside of the VM:
# sudo apt install openssh-server
# sudo passwd user
#   set password to: user
# For kali:
# sudo systemctl start ssh

mount_exec() {
    sudo mkdir /vagrant
    sudo mount -t vboxsf vagrant /vagrant
    cd /vagrant/scripts/
    echo 'VERSION_CODENAME=bookworm' | sudo tee -a /etc/os-release
    sudo ./k3d.sh && ./argocd.sh
}
