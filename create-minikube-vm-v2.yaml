## Check if the script is run with bash as shell interpreter.
if [ -z "$BASH_VERSION" ] ; then
   echo 'Boot Info Script needs to be run with bash as shell interpreter.' >&2;
   exit 1;
fi

help () {
   cat <<- HELP

	Create minikube VirtualBox VM Script:
	-----------------------
    ./create-minikube-vm <virtual machine name> <cloud image filename.ova>

	HELP

   exit 0;
}
parameterCount=$#
if (( parameterCount != 2 )); then
    echo "Illegal number of parameters: $parameterCount!\n";
    help;
    exit 1;
fi

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
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - $publicKey

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
 - "export CHANGE_MINIKUBE_NONE_USER=true"
 - "sudo minikube start --vm-driver none"
 - "sudo minikube addons enable ingress"
 - "sudo kubectl apply -f https://raw.githubusercontent.com/JunkMail4MJD/cloud-init-fun/master/dashboard-ingress-rule.yaml -n kube-system"
 - "sudo kubectl get all --all-namespaces"
EOF

cat <<EOF > meta-data
instance-id: id-12346
local-hostname: $vmname
EOF


cloud-localds config-data.iso user-data meta-data

VBoxManage import "$cloudimage" --vsys 0 --vmname "$vmname" --cpus 4 --memory 4096

VBoxManage modifyvm "$vmname" --uart1 0x03f8 4 --uartmode1 file "$(pwd)"/"$vmname"-output.txt

VBoxManage storageattach "$vmname" \
    --storagectl "IDE" --port 1 --device 0 \
    --type dvddrive --medium "$(pwd)"/config-data.iso
## --bridgeadapter<1-N> none|<devicename>

VBoxManage startvm "$vmname"

printf "When your new machine has finished booting,\n"
printf "ssh into your new box with the following command:\n\n"
printf "   ssh ubuntu@$vmname -i "$(pwd)"/"$vmname"-key\n\n"
