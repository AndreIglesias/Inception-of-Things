#!/bin/bash

# Set up VM properties
VM_NAME="p3"

# Current directory
CURRENT_DIR=$(pwd)

# Define file names
VBOX_FILE="p3.vbox"

# Create VM
VBoxManage registervm "$VBOX_FILE"

# Mount current directory as /vagrant in the VM
VBoxManage sharedfolder add "$VM_NAME" --name "vagrant" --hostpath "$CURRENT_DIR"

# Start VM
VBoxManage startvm "$VM_NAME"

sleep 10
# Press enter to skip the boot menu
VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c

# Inside of the VM:
# sudo apt install openssh-server
# sudo passwd user
#   set password to: user

mount_exec() {
    mkdir vagrant
    sudo mount -t vboxsf vagrant vagrant/
    cd vagrant/scripts/
    sudo ./k3d.sh && sudo ./argocd.sh
}
