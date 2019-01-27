#!/bin/bash

help () {
  cat <<- END
	HELP: Script to create VirtualBox VMs using cloud-init (similar to AWS EC2)
  ------------------------------------------

    ./create-generic-vm.sh  <virtual machine name>

    Example: ./create-generic-vm.sh generic-18 

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

./create-vm.sh $1 images/ubuntu-18.04-server-cloudimg-amd64.vdi yaml-files/generic-vm.yaml 2048 1 10240