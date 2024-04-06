#!/bin/bash

# Set up VM properties
VM_NAME="p3"
VM_MEMORY="4096"  # in MB
VM_CPUS="4"

# Provisioning scripts
K3D_SCRIPT="scripts/k3d.sh"
ARGOCD_SCRIPT="scripts/argocd.sh"

# Forwarded ports
PORT_1="8443"
PORT_2="8888"
PORT_3="8822"

# Current directory
CURRENT_DIR=$(pwd)

# URL for Debian ISO
DEBIAN_ISO_URL="https://saimei.ftp.acc.umu.se/debian-cd/current-live/amd64/iso-hybrid/debian-live-12.5.0-amd64-standard.iso"
DEBIAN_ISO_FILE="debian-live-12.5.0-amd64-standard.iso"

# Download Debian ISO
if [ -f "$DEBIAN_ISO_FILE" ]; then
    echo "Debian ISO already downloaded."
else
    echo "Downloading Debian ISO..."
    curl -o "$DEBIAN_ISO_FILE" "$DEBIAN_ISO_URL"
fi

# Create VM
VBoxManage createvm --name "$VM_NAME" --register

# Set memory and CPUs
VBoxManage modifyvm "$VM_NAME" --memory "$VM_MEMORY"
VBoxManage modifyvm "$VM_NAME" --cpus "$VM_CPUS"

# Set box (use the Debian ISO)
VBoxManage modifyvm "$VM_NAME" --ostype Debian_64
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage createmedium disk --filename "debian_disk.vdi" --size 40480  # Create a virtual disk to install Debian (adjust size as needed)
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "debian_disk.vdi"

VBoxManage storagectl $VM_NAME --name IDE --add ide --controller PIIX4 --bootable on
VBoxManage storageattach $VM_NAME --storagectl IDE --port 0 --device 0 --type dvddrive --medium $DEBIAN_ISO_FILE

# Define network ports
VBoxManage modifyvm "$VM_NAME" --natpf1 "guest$PORT_1,tcp,,$PORT_1,,$PORT_1"
VBoxManage modifyvm "$VM_NAME" --natpf1 "guest$PORT_2,tcp,,$PORT_2,,$PORT_2"
VBoxManage modifyvm "$VM_NAME" --natpf1 "guest22,tcp,,$PORT_3,,22"

# Mount current directory as /vagrant in the VM
VBoxManage sharedfolder add "$VM_NAME" --name "vagrant" --hostpath "$CURRENT_DIR"

VBoxManage modifyvm "$VM_NAME" --nic1 nat

# Start VM
VBoxManage startvm "$VM_NAME" --type headless

sleep 10  # Wait for VM to fully boot
VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c  # Press Enter to boot from the ISO

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
