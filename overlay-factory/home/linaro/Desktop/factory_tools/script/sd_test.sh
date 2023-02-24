#!/bin/bash

para=$1

sd_blk=$(lsblk | grep mmcblk1)
if [ ! "$sd_blk" ]; then
	echo "FAIL"
	exit
fi

sd_name=$(sudo cat /sys/bus/mmc/devices/mmc1:*/name)
sd_size=$(sudo /sbin/fdisk -l /dev/mmcblk1 | grep Disk | awk '{print $5}')
sd_size_MB=`awk 'BEGIN{printf "%d\n",('$sd_size'/1024/1024)}'`

if [ "$para" = "name" ]; then
	echo $sd_name
elif [ "$para" = "size" ]; then
	echo $sd_size
else
	echo "PASS, $sd_name, $sd_size"
fi

