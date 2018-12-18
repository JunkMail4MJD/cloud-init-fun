#!/bin/bash
help () {
  cat <<- END
	HELP: Script to delete VirtualBox VMs
  ------------------------------------------
    ./cleanup-vm.sh  <virtual machine name>

    Example: ./cleanup-vm.sh mini-01

	END
}
parameterCount=$#
if (( parameterCount != 1 )); then
  RED="\033[1;31m"
  RESET="\033[0;0m"
  printf "\n${RED}Illegal number of parameters: ${parameterCount}!\n\n${RESET}------------------------------------------\n";
  help;
  exit 1;
fi

echo "Deleting Virtual Machine ${1}"


vmname=$1
cloudimage=$2

ssh-keygen -t rsa -C ubuntu -f "$(pwd)"/"$vmname"-key -N ""
publicKey=$(head -n 1 "$(pwd)"/"$vmname"-key.pub)

cat <<EOF > user-data
#cloud-config
users:
  - name: ubuntu
    plain_text_passwd: 'password'
    lock_passwd: False
    gecos: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - $publicKey

system_info:
  default_user:
   name: ubuntu
   plain_text_passwd: 'password'
   home: /home/ubuntu
   shell: /bin/bash
   lock_passwd: False
   groups: [sudo, adm ]
   shell: /bin/bash
packages:
 - docker.io
runcmd:
 - "ip addr"
 - "df -h"
 - [ update-grub ]
 - "docker run -d --name thisNginx --network host nginx:1.14-alpine"
EOF

cat <<EOF > meta-data
instance-id: id-12346
local-hostname: $vmname
EOF

cloud-localds config-data.iso user-data meta-data

VBoxManage import "$cloudimage" --vsys 0 --vmname "$vmname" --cpus 1 --memory 2048

VBoxManage modifyvm "$vmname" --uart1 0x03f8 4 --uartmode1 file "$(pwd)"/"$vmname"-output.txt

VBoxManage storageattach "$vmname" \
    --storagectl "IDE" --port 1 --device 0 \
    --type dvddrive --medium "$(pwd)"/config-data.iso
## --bridgeadapter<1-N> none|<devicename>

VBoxManage startvm "$vmname"

printf "When your new machine has finished booting,\n"
printf "ssh into your new box with the following command:\n\n"
printf "   ssh ubuntu@$vmname -i "$(pwd)"/"$vmname"-key\n\n"
