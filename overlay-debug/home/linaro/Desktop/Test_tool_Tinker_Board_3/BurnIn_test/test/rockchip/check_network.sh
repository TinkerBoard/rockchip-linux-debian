#!/bin/bash

sleep 5
err_cnt=0
logfile=$1

log()
{
	start_time="$(date +'%Y/%m/%d/%H:%M:%S')"
	echo -e $start_time "check_network " $1 | sudo tee -a $logfile
}

while [ $err_cnt != 2 ]
do
	if ip netns exec ns_server ping -c 1 192.168.100.99 &> /dev/null
	then
		err_cnt=0
	else
		((err_cnt+=1))
	fi
	sleep 3
done

log "ping fail and kill network_stress_test.sh"
killall network_stress_test.sh > /dev/null 2>&1
killall iperf3 > /dev/null 2>&1
