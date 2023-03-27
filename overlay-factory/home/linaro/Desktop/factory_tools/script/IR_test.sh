#!/bin/bash

dbg_code=$(sudo su -c "echo 1 > /sys/module/rockchip_pwm_remotectl/parameters/code_print")

time=0
end_time=$1
usercode1=""
usercode2=""
result1=""
result2=""
origin_number=$(($(dmesg | grep USERCODE | awk -F '=' {'print NR'} | tail -1)+2))

if [ -n "$1" ]; then
	end_time=$1
else
	end_time=10
fi

while [ "1" -ne "2" ]
do
	sleep 1
	time=$(($time+1))

	usercode1=$(dmesg | grep USERCODE | awk -F '=' {'print NR,$2'} | tail -2 | head -1 | awk '{print $2}')
	usercode2=$(dmesg | grep USERCODE | awk -F '=' {'print NR,$2'} | tail -1 | awk '{print $2}')
	result1=$(dmesg | grep RMC_GETDATA | awk -F '=' {'print NR,$2'} | tail -2 | head -1 | awk '{print $2}')
	result2=$(dmesg | grep RMC_GETDATA | awk -F '=' {'print NR,$2'} | tail -1 | awk '{print $2}')
	result_number=$(dmesg | grep USERCODE | awk -F '=' {'print NR'} | tail -1)

	if [ "$result_number" -ge "$origin_number" 2> /dev/null ] && [ -n "$usercode1" ] && [ -n "$usercode2" ] && [ -n  "$result1" ] && [ -n "$result2" ] && [ "$usercode1" == "$usercode2" ] && [ "$result1" == "$result2" ]; then
		echo "PASS"
		exit
	elif [ "$time" == "$end_time" ]; then
		echo "FAIL"
		exit
	fi
done