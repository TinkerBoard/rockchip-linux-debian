#!/bin/bash

ethtool=/usr/sbin/ethtool

function Ethernet_Led_Test()
{
	LAN_PORT="$1"
	SPEED="$2"

	if [[ $LAN_PORT == "eth0" ]] || [[ $LAN_PORT == "eth1" ]]; then
		echo "Ethernet : led test ($LAN_PORT)"
	else
		echo "Error : please add parameter eth0/eth1 10/100/1000/reset"
		return 1
	fi

	case "$SPEED" in
		'10')
			echo "speed : 10m"
			sudo $ethtool -s $LAN_PORT speed 10 duplex full autoneg off
			;;
		'100')
			echo "speed : 100m"
			sudo $ethtool -s $LAN_PORT speed 100 duplex full autoneg off
			;;
		'1000')
			echo "speed : 1000m"
			sudo $ethtool -s $LAN_PORT speed 1000 duplex full autoneg on
			;;
		'reset')
			echo "speed : reset"
			sudo $ethtool -s $LAN_PORT speed 1000 duplex full autoneg on
			;;
	esac
}

Ethernet_Led_Test "$@"
if [[ $? -eq 0 ]]; then
	echo "FINISH"
else
	echo "FAIL"
fi
