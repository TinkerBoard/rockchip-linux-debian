#!/bin/bash

ifconfig=/usr/sbin/ifconfig

function Ethernet_Check_MAC()
{
	LAN_PORT="$1"
	MAC="$2"

	if [[ $LAN_PORT == "eth0" ]]; then
		echo "Ethernet (eth0) : check mac... : $MAC"
	elif [[ $LAN_PORT == "eth1" ]]; then
		echo "Ethernet (eth1) : check mac... : $MAC"
	else
		echo "Error : please add parameter eth0/eth1 mac-address"
		return 1
	fi

	get_mac=$($ifconfig $LAN_PORT | grep ether | awk '{print $2}')
	current_mac=$(echo $get_mac | sed 's/://g')
	echo "Get Current MAC : " $current_mac

	if echo "$MAC" | grep -qwi "$current_mac"; then
		return 0
	else
		return 1
	fi
}

Ethernet_Check_MAC "$@"
if [[ $? -eq 0 ]]; then
	echo "PASS"
else
	echo "FAIL"
fi
