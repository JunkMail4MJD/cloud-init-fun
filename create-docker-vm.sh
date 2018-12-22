#!/bin/bash
originalMachineFolder=$(VBoxManage list systemproperties | grep -i "default machine folder:" | cut -b 24- | awk '{gsub(/^ +| +$/,"")}1')
set -e
trap 'handleError' EXIT

help () {
  cat <<- END
	HELP: Script to create VirtualBox VMs using cloud-init (similar to AWS EC2)
  ------------------------------------------

    ./create-generic-vm.sh  <virtual machine name> <cloud image virtual disk.vmdk>

    Example: create-generic-vm.sh generic-18 ubuntu-18.04-server-cloudimg-amd64.vmdk

	END
}

handleError(){

  if [ $? -gt 0 ]
  then
    echo "exit $? due to ${BASH_COMMAND}"
    if test -z "${originalMachineFolder}"
    then
      echo " "
    else
      vboxmanage setproperty machinefolder ${originalMachineFolder}
    fi
  fi
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
    lock_passwd: False
    home: /home/ubuntu
    shell: /bin/bash
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
write_files:
  - encoding: b64
    content: |
      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
      +X/inyMuOlkAUAAA
    owner: ubuntu:ubuntu
    path: /usr/src/docker/config.tar.gz
    permissions: '0644'
runcmd:
  - "update-grub"
  - "printf 'Showing IP address\n'"
  - "ip addr"
  - "printf 'Showing disk space\n'"
  - "df -h"
  - "printf 'Extracting docker mirror config file\n'"
  - "tar -xzvf /usr/src/docker/config.tar.gz  --directory=/etc/docker"
  - "printf 'Stopping Docker\n'"
  - "systemctl stop docker"
  - "printf 'Restarting Docker\n'"
  - "systemctl start docker"
  - "printf 'showing local files\n'"
  - "ls -alGh /home/ubuntu/"
  - "ls -alGh /root/"
  - "ls -alGh /etc/docker"
EOF

instanceId=$(openssl rand -hex 8)
cat <<EOF > "${vmname}/meta-data"
instance-id: ${instanceId}
local-hostname: ${vmname}
EOF

docker run --rm -d --name cloud-init-creator -v ${basefolder}${vmname}/:/usr/src/files junkmail4mjd/cloud-init-creator:v0.0.1

##------------------ setup variables
bootDisk=${vmname}/disk-1.vdi

vboxmanage setproperty machinefolder ${basefolder}
##------------------ Define Virtual Machine
VBoxManage import appliances/empty-cloudimg.ovf --vsys 0 --vmname "$vmname" --cpus 2 --memory 6000
VBoxManage modifyvm ${vmname} --uart1 0x03f8 4 --uartmode1 file "${basefolder}${vmname}/console-output.log"
VBoxManage storagectl ${vmname} --name "IDE" --add ide --controller PIIX4
VBoxManage storagectl ${vmname} --name "SCSI" --add scsi --controller Lsilogic
VBoxManage storageattach "${vmname}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "${basefolder}${vmname}/config-data.iso"
VBoxManage clonehd ${cloudimage} ${bootDisk} --format vdi
VBoxManage modifymedium disk ${vmname}/disk-1.vdi --resize 102400
VBoxManage storageattach ${vmname} --storagectl "SCSI" --port 0 --device 0 --type hdd --medium ${bootDisk}

VBoxManage setproperty machinefolder ${originalMachineFolder}

##------------------ start virtual machine
VBoxManage startvm "${vmname}" --type headless

printf "When your new machine has finished booting,\n"
printf "ssh into your new box with the following command:\n\n"
printf "   ssh ubuntu@${vmname} -i ${basefolder}${vmname}/${vmname}-key\n\n"
