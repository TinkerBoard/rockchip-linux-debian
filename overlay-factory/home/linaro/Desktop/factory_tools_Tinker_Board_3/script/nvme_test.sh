#!/bin/bash

para=$1

ssd_blk=$(lsblk | grep nvme0n1)
if [ ! "$ssd_blk" ]; then
	echo "FAIL"
	exit
fi

ssd_name=$(sudo cat /sys/class/nvme/nvme0/model)
ssd_size=$(sudo cat /sys/class/nvme/nvme0/nvme0n1/size)
ssd_size_MB=`awk 'BEGIN{printf "%d\n",('$ssd_size'/1024/1024)}'`

if [ "$para" = "name" ]; then
	echo $ssd_name
elif [ "$para" = "size" ]; then
	echo $ssd_size
else
	echo "PASS, $ssd_name, $ssd_size"
fi

