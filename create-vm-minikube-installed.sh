#!/bin/bash
help () {
  cat <<- END
	HELP: Script to create VirtualBox VMs using cloud-init (similar to AWS EC2)
  ------------------------------------------

    This script creates a virtual machine that has minikube installed and kubectl installed but no cluster.

    ./create-vm-minikube-installed.sh  <virtual machine name> <cloud image appliance file - ova>

    Example: create-vm-minikube-installed.sh mini-18 ubuntu-18.04-server-cloudimg-amd64.ova

	END
}
parameterCount=$#
if (( parameterCount != 2 )); then
  RED="\033[1;31m"
  RESET="\033[0;0m"
  printf "\n${RED}Illegal number of parameters: ${parameterCount}!\n\n${RESET}------------------------------------------\n";
  help;
  exit 1;
fi

echo "Creating virtual machine ${1} based on ${2}"

vmname=$1
cloudimage=$2
basefolder="$(pwd)/"

mkdir -p "${basefolder}${vmname}"
ssh-keygen -t rsa -C ubuntu -f "${basefolder}${vmname}/${vmname}-key" -N ""
publicKey=$(head -n 1 "${basefolder}${vmname}/${vmname}-key.pub")

cat <<EOF > "${vmname}/user-data"
#cloud-config
users:
  - name: ubuntu
    plain_text_passwd: 'password'
    home: /home/ubuntu
    shell: /bin/bash
    lock_passwd: False
    gecos: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ${publicKey}
system_info:
  default_user:
   name: ubuntu
   groups: [sudo, adm ]
packages:
 - docker.io
runcmd:
 - "ip addr"
 - "df -h"
 - [ update-grub ]
 - "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
 - "chmod +x ./kubectl"
 - "sudo mv ./kubectl /usr/local/bin/kubectl"
 - "curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.31.0/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube"
EOF

instanceId=$(openssl rand -hex 8)
cat <<EOF > "${vmname}/meta-data"
instance-id: ${instanceId}
local-hostname: ${vmname}
EOF

docker run --rm -d --name cloud-init-creator -v ${basefolder}${vmname}/:/usr/src/files junkmail4mjd/cloud-init-creator:v0.0.1

##------------------ setup variables
imageName=images/ubuntu-18.04-server-cloudimg-amd64.vmdk
bootDisk=${vmname}/disk-1.vdi

##------------------ Define Virtual Machine
vboxmanage createvm --name ${vmname} --ostype Linux_64 --basefolder ${basefolder} --register
VBoxManage storagectl ${vmname} --name "IDE" --add ide --controller PIIX4
VBoxManage storagectl ${vmname} --name "SCSI" --add scsi --controller Lsilogic
VBoxManage clonehd ${imageName} ${bootDisk} --format vdi
VBoxManage modifymedium disk ${vmname}/disk-1.vdi --resize 102400
VBoxManage storageattach ${vmname} --storagectl "SCSI" --port 0 --device 0 --type hdd --medium ${bootDisk}
VBoxManage modifyvm ${vmname} --uart1 0x03f8 4 --uartmode1 file "${basefolder}${vmname}/console-output.log"
VBoxManage modifyvm ${vmname} --memory 6144 --vram 128 --cpus 4
VBoxManage modifyvm ${vmname} --nic1 bridged --bridgeadapter1 en0
VBoxManage storageattach "${vmname}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "${basefolder}${vmname}/config-data.iso"


##------------------ start virtual machine
VBoxManage startvm "${vmname}"

printf "When your new machine has finished booting,\n"
printf "ssh into your new box with the following command:\n\n"
printf "   ssh ubuntu@${vmname} -i ${basefolder}${vmname}/${vmname}-key\n\n"
