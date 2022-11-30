#!/bin/bash
logfile=$2
wifi_gw=$(route -n | grep wlan0 | grep UG | awk {'printf $2'})

sleep 5
pass_cnt=0
err_cnt=0
while [ 1 != 2 ]
do
	if ping -c 1 $wifi_gw &> /dev/null
	then
		status="pass"
		((pass_cnt+=1))
	else
		status="fail"
		((err_cnt+=1))
	fi

	echo "$(date +'%Y%m%d_%H%M'): last ping $status , pass_cnt=$pass_cnt, err_cnt=$err_cnt" | tee -a $logfile

	sleep 1
done
