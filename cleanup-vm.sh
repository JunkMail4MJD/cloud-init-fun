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

VBoxManage controlvm "$vmname" poweroff
sleep 5
VBoxManage unregistervm "$vmname" --delete

rm -Rf "$(pwd)/$vmname"
