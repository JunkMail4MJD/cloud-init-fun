#!/bin/bash
help () {
  cat <<- END
	HELP: Script to create VirtualBox VMs using cloud-init (similar to AWS EC2)
  ------------------------------------------
    ./create-generic-vm.sh  <virtual machine name> <cloud image appliance file - ova>

    Example: create-generic-vm.sh mini-01 ubuntu-18.04-server-cloudimg-amd64.ova

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

mkdir -p "$(pwd)/${vmname}"
ssh-keygen -t rsa -C ubuntu -f "$(pwd)/${vmname}/${vmname}"-key -N ""
publicKey=$(head -n 1 "$(pwd)/${vmname}/${vmname}"-key.pub)

cat <<EOF > "${vmname}/user-data"
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

docker run --rm -d --name cloud-init-creator -v $(pwd)/${vmname}/:/usr/src/files junkmail4mjd/cloud-init-creator:v0.0.1

VBoxManage import "$cloudimage" --vsys 0 --vmname "${vmname}" --cpus 1 --memory 2048

VBoxManage modifyvm "${vmname}" --uart1 0x03f8 4 --uartmode1 file "$(pwd)/${vmname}/${vmname}"-output.txt

VBoxManage storageattach "${vmname}" \
    --storagectl "IDE" --port 1 --device 0 \
    --type dvddrive --medium "$(pwd)/${vmname}/config-data.iso"
## --bridgeadapter<1-N> none|<devicename>

VBoxManage startvm "${vmname}"

printf "When your new machine has finished booting,\n"
printf "ssh into your new box with the following command:\n\n"
printf "   ssh ubuntu@${vmname} -i $(pwd)/${vmname}/${vmname}-key\n\n"
