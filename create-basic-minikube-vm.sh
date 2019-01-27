#!/bin/bash

help () {
  cat <<- END
	HELP: Script to create VirtualBox VMs using cloud-init (similar to AWS EC2)
  ------------------------------------------

    ./create-basic-minikube-vm.sh  <virtual machine name>

    Example: ./create-basic-minikube-vm.sh minikube-01 

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

./create-vm.sh $1 images/ubuntu-18.04-server-cloudimg-amd64.vdi yaml-files/docker-vm.yaml 8192 4 102400
