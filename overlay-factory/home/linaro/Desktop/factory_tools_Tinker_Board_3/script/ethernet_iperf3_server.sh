#!/bin/bash

iperf3=/usr/bin/iperf3
eth0_iperf3_ip="192.168.100.100"
eth1_iperf3_ip="192.168.99.100"

function Ethernet_Iperf3_Server()
{
	LAN_PORT="$1"

	killall iperf3
	skeep 0.5

	if [[ $LAN_PORT == "eth0" ]]; then
		echo "Ethernet : iperf3 server ($LAN_PORT)"
		sudo $iperf3 -s -B $eth0_iperf3_ip -i 1 &
	elif [[ $LAN_PORT == "eth1" ]]; then
		echo "Ethernet : iperf3 server ($LAN_PORT)"
		sudo $iperf3 -s -B $eth1_iperf3_ip -i 1 &
	else
		echo "Error : please add parameter eth0/eth1"
		return 1
	fi
}

Ethernet_Iperf3_Server "$@"
if [[ $? -eq 0 ]]; then
	echo "FINISH"
else
	echo "FAIL"
fi
