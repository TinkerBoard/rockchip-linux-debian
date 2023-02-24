#!/bin/bash

ping=/usr/bin/ping
eth0_ping_ip="192.168.100.101"
eth1_ping_ip="192.168.99.101"

function Check_Network_Status()
{
	echo "Check Network Status: $1: $2"
	for i in {1..16}
	do
		ret=`sudo ping -c 1 -I $1 $2`
		if [[ $ret == *" 0% packet loss"* ]]; then
			echo "Check Pass"
			return 0
		elif [[ $i == 16 ]]; then
			echo "Network Status Error, Please Check IP Status"
			exit 0
		fi
		echo check lan status... "("$1")"
		sleep 1
	done
}

function Ethernet_Ping_Test()
{
	LAN_PORT="$1"
	COUNTS="$2"

	if [[ $LAN_PORT == "eth0" ]]; then
		echo "Ethernet : ping test ($LAN_PORT), counts = $COUNTS"
		Check_Network_Status $LAN_PORT $eth0_ping_ip
		ret=`sudo $ping -I $LAN_PORT -c $COUNTS $eth0_ping_ip`
	elif [[ $LAN_PORT == "eth1" ]]; then
		echo "Ethernet : ping test ($LAN_PORT), counts = $COUNTS"
		Check_Network_Status $LAN_PORT $eth1_ping_ip
		ret=`sudo $ping -I $LAN_PORT -c $COUNTS $eth1_ping_ip`
	else
		echo "Error : please add parameter eth0/eth1 counts"
		return 1
	fi

	ping_log=$(echo $ret | awk -F '---' '{print $3}')
	echo $ping_log

	if [[ $ret == *" 0% packet loss"* ]]; then
		return 0
	else
		return 1
	fi
}

Ethernet_Ping_Test "$@"
if [[ $? -eq 0 ]]; then
	echo "PASS"
else
	echo "FAIL"
fi
