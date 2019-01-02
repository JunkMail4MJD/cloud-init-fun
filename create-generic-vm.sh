#!/bin/bash
originalMachineFolder=$(VBoxManage list systemproperties | grep -i "default machine folder:" | cut -b 24- | awk '{gsub(/^ +| +$/,"")}1')
printf "\n\nSaving default machine folder ${originalMachineFolder}\n\n"

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
      vboxmanage setproperty machinefolder /'${originalMachineFolder}/'
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

printf "\n\nCreating virtual machine ${1} based on ${2}\n\n"

vmname=$1
cloudimage=$2
basefolder="$(pwd)/"

printf "\n\n....  1. Creating directory for virtual machine: ${basefolder}${vmname}\n\n"
mkdir -p "${basefolder}${vmname}"
printf "\n\n....  2. Creating SSH key pair \n\n"
ssh-keygen -t rsa -C ubuntu -f "${basefolder}${vmname}/${vmname}-key" -N ""
publicKey=$(head -n 1 "${basefolder}${vmname}/${vmname}-key.pub")

printf "\n\n....  3. Creating cloud-init file: ${vmname}/user-data\n\n"
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
runcmd:
 - "ip addr"
 - "df -h"
 - [ update-grub ]
 - "docker run -d --name thisNginx --network host nginx:1.14-alpine"
EOF

printf "\n\n....  4. Creating instance metadata: ${vmname}/meta-data\n\n"
instanceId=$(openssl rand -hex 8)
cat <<EOF > "${vmname}/meta-data"
instance-id: ${instanceId}
local-hostname: ${vmname}
EOF

printf "\n\n....  5. Converting cloud-init files into ISO image\n\n"
sudo docker run --rm -d --name cloud-init-creator -v ${basefolder}${vmname}/:/usr/src/files junkmail4mjd/cloud-init-creator:v0.0.1

##------------------ setup variables
bootDisk=${vmname}/disk-1.vdi

printf "\n\n....  6. Setting virtual machine directory: ${basefolder}\n\n"
vboxmanage setproperty machinefolder ${basefolder}

##------------------ Define Virtual Machine
printf "\n\n....  7. Importing raw appliance \n\n"
VBoxManage import appliances/empty-cloudimg.ovf --vsys 0 --vmname "$vmname" --cpus 1 --memory 2048

printf "\n\n....  8. Adding serial port of logging console\n\n"
VBoxManage modifyvm ${vmname} --uart1 0x03f8 4 --uartmode1 file "${basefolder}${vmname}/console-output.log"

printf "\n\n....  9. Adding IDE Controller\n\n"
VBoxManage storagectl ${vmname} --name "IDE" --add ide --controller PIIX4

printf "\n\n.... 10. Adding SCSI Controller\n\n"
VBoxManage storagectl ${vmname} --name "SCSI" --add scsi --controller Lsilogic

printf "\n\n.... 11. Attaching ISO image\n\n"
VBoxManage storageattach "${vmname}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "${basefolder}${vmname}/config-data.iso"

printf "\n\n.... 12. Resizing cloud Image ${cloudimage} :: as :: ${bootDisk}\n\n"
VBoxManage clonehd ${cloudimage} ${bootDisk} --format vdi
VBoxManage modifymedium disk ${vmname}/disk-1.vdi --resize 102400

printf "\n\n.... 13. Attaching cloud image boot disk\n\n"
VBoxManage storageattach ${vmname} --storagectl "SCSI" --port 0 --device 0 --type hdd --medium ${bootDisk}

printf "\n\n.... 14. Resetting default machine folder ${originalMachineFolder}\n\n"
VBoxManage setproperty machinefolder /'${originalMachineFolder}/'

##------------------ start virtual machine
printf "\n\n.... 15. Starting virtual machine ${vmname}\n\n"
VBoxManage startvm "${vmname}" --type headless

printf "When your new machine has finished booting,\n"
printf "ssh into your new box with the following command:\n\n"
printf "   ssh ubuntu@${vmname} -i ${basefolder}${vmname}/${vmname}-key\n\n"
