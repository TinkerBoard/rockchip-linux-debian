#!/bin/bash

#disalbe thermal
echo "Setting CPU / GPU / DDR in highest performance mode"
for i in `ls /sys/devices/system/cpu/ | grep cpu[0-9]`
do
	echo "performance" > /sys/devices/system/cpu/$i/cpufreq/scaling_governor
done

if [ $1 -a $1 == 2 ]; then
	echo keep thermal
else
	echo disable thermal
	if [ -e /sys/class/thermal/thermal_zone0 ]; then
		echo user_space >/sys/class/thermal/thermal_zone0/policy
		echo disabled > /sys/class/thermal/thermal_zone0/mode
		echo 0 > /sys/class/thermal/thermal_zone0/cdev0/cur_state
		echo 0 > /sys/class/thermal/thermal_zone0/cdev1/cur_state
		echo 0 > /sys/class/thermal/thermal_zone0/cdev2/cur_state
		echo 0 > /sys/class/thermal/thermal_zone0/cdev3/cur_state
	fi
fi
