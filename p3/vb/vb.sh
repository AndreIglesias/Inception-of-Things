#!/bin/bash

# Set up VM properties
VM_NAME="p3"

# Forwarded ports
PORT_1="8443"
PORT_2="8888"
PORT_3="8822"

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

# Define network ports
#VBoxManage modifyvm "$VM_NAME" --natpf1 "guest$PORT_1,tcp,,$PORT_1,,$PORT_1"
#VBoxManage modifyvm "$VM_NAME" --natpf1 "guest$PORT_2,tcp,,$PORT_2,,$PORT_2"
#VBoxManage modifyvm "$VM_NAME" --natpf1 "guest22,tcp,,$PORT_3,,22"

# Mount current directory as /vagrant in the VM
VBoxManage sharedfolder add "$VM_NAME" --name "vagrant" --hostpath "$PARENT_DIR" 

# Set network to NAT
#VBoxManage modifyvm "$VM_NAME" --nic1 nat

# Start VM
VBoxManage startvm "$VM_NAME"

#sleep 10
# Press enter to skip the boot menu
#VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c

# Inside of the VM:
# sudo apt install openssh-server
# sudo passwd user
#   set password to: user
# For kali:
# sudo systemctl start ssh

mount_exec() {
    mkdir vagrant
    sudo mount -t vboxsf vagrant vagrant/
    cd vagrant/scripts/
    sudo ./k3d.sh && sudo ./argocd.sh
}
