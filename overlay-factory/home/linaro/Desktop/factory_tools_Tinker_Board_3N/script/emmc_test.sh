#!/bin/bash

para=$1

emmc_name=$(sudo cat /sys/bus/mmc/devices/mmc0:0001/name)
emmc_life_time=$(sudo cat /sys/bus/mmc/devices/mmc0:0001/life_time)
emmc_pre_eol_info=$(sudo cat /sys/bus/mmc/devices/mmc0:0001/pre_eol_info)
emmc_size=$(sudo /sbin/fdisk -l /dev/mmcblk0 | grep Disk | awk '{print $5}')
emmc_size_MB=`awk 'BEGIN{printf "%d\n",('$emmc_size'/1024/1024)}'`

if [ "$para" = "name" ]; then
	echo $emmc_name
elif [ "$para" = "life_time" ]; then
	echo $emmc_life_time
elif [ "$para" = "pre_eol_info" ]; then
	echo $emmc_pre_eol_info
elif [ "$para" = "size" ]; then
	echo $emmc_size
elif [ "$para" = "erase" ]; then
	sudo /usr/sbin/blkdiscard /dev/mmcblk0
else
	echo "$emmc_name, $emmc_life_time, $emmc_pre_eol_info, $emmc_size"
fi

