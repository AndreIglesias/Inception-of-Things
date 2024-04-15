#!/bin/bash

# Set up VM properties
VM_NAME="p3"

# Parent directory
PARENT_DIR=$(dirname "$PWD")

# .vbox file
VBOX_FILE="p3.vbox"
# https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-virtualbox-amd64.7z

# Create backup for .vbox
if [ -f "$VBOX_FILE" ]; then
    cp "$VBOX_FILE" "$VBOX_FILE.bkp"
fi

ZIP_FILE="kali-linux-2024.1-virtualbox-amd64.7z"
VDI_FILE="kali-linux-2024.1-virtualbox-amd64.vdi"

if [[ ! -f "$ZIP_FILE" && ! -f "$VDI_FILE" ]]; then

    curl -o "$ZIP_FILE" "https://kali.download/base-images/kali-2024.1/$ZIP_FILE"

    # Check if download was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download $ZIP_FILE"
        exit 1
    fi
fi

if [ ! -f "$VDI_FILE" ]; then
    docker run -v "$(pwd)":/data ubuntu bash -c "apt-get update && apt-get install -y p7zip-full && cd /data && 7z x $ZIP_FILE && ls -lR"
    ln -s kali-linux-2024.1-virtualbox-amd64/$VDI_FILE .
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
