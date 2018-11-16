#!/bin/bash

############### CHECKING ALL THE REQUIREMENT BEFORE RUNNING THE SCRIPT ############################

list_vms="toronto ottawa cloyne"
vms="172.17.15.2 172.17.15.3 172.17.15.100"
function check() {
	if eval $1
	then
		echo -e "\e[32mOKAY_Babe. Good job \e[0m"
	else
		echo
     		echo
     		echo -e "\e[0;31mWARNING\e[m"
     		echo
     		echo
     		echo $2
     		echo
     		exit 1
	fi	
}

echo -e "\e[1;31m--------WARNING----------"
echo -e "\e[1mBackup your virtual machine to run this script \e[0m"
echo
read -p "Did you make a backup ? [Y/N]: " choice
while [[ "$choice" != "Y" && "$choice" != "Yes" && "$choice" != "y" && "$choice" != "yes" ]]
do
	echo -e "\e[33mGo make a backup \e[0m" >&2
	exit 6
done

########## INPUT from USER #######
read -p "What is your IP Adress of VM1: " IP
fdigit=$( echo "$IP" | awk -F. '{print $1"."$2"."$3}' )
check "ifconfig | grep $fdigit > /dev/null" "Wrong Ip address of VM1"
intvm=$(ifconfig | grep -B 1 $fdigit.1 | head -1 | awk -F: '{print $1}')
echo
intclone=$(ifconfig | grep -B 1 172.17.15.1 | head -1 | awk -F: '{print $1}')
read -p "What is your Matrix account ID: " userid


### Check if you are root ###
if [ `id -u` -ne 0 ]
then
	echo "Must run this script by root" >&2
	exit 1 
fi

### Check vms are online: Toronto, Ottawa
echo "Checking VMs status"

for i in $list_vms
do 
	if ! virsh list | grep -iqs $i
	then
		echo -e "\e[1;31mMust turn on $i  \e[0m" >&2
		exit 2
	fi

done

echo "-------Restarting Named-----------"
systemctl restart named
echo -e "--------\e[32mRestarted Done \e[0m----------"