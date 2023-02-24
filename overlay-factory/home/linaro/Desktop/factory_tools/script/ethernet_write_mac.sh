#!/bin/bash

i2cget=/usr/sbin/i2cget
i2cset=/usr/sbin/i2cset
i2cdump=/usr/sbin/i2cdump

function Ethernet_Write_MAC()
{
	LAN_PORT="$1"
	MAC="$2"

	echo ""
	if [[ $LAN_PORT == "eth0" ]]; then
		echo "Ethernet (eth0) : write mac address ($MAC) to eeprom"
		flag=0
	elif [[ $LAN_PORT == "eth1" ]]; then
		echo "Ethernet (eth1) : write mac address ($MAC) to eeprom"
		flag=6
	else
		"Error : please add parameter eth0/eth1 mac_address"
		return 1
	fi

	eeprom_address=$flag

	for ((i=0;i<12;i=i+2))
	do
		sudo $i2cset -f -y 2 0x50 $eeprom_address 0x${MAC:$i:2}
		let "eeprom_address=$eeprom_address+1"
	done

	sudo $i2cdump -y -f 2 0x50
	echo ""
	echo "Ethernet ($LAN_PORT): read eeprom to check mac"
	eeprom_address=$flag

	for ((i=$eeprom_address;i<$(($eeprom_address+6));i=i+1))
	do
		sudo $i2cget -f -y 2 0x50 $i
	done

	echo ""
	return 0

}

Ethernet_Write_MAC "$@"
if [[ $? -eq 0 ]]; then
	echo "FINISH"
else
	echo "FAIL"
fi
