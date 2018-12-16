vmname=$1

VBoxManage controlvm "$vmname" poweroff
sleep 5
VBoxManage unregistervm "$vmname" --delete

rm user-data
rm meta-data
rm config-data.iso
rm "$(pwd)"/"$vmname"-output.txt
rm "$(pwd)"/"$vmname"-key
rm "$(pwd)"/"$vmname"-key.pub
