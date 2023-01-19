#!/bin/bash

iface=can0
rx_err_cnt=0
if [[ -n "$1" ]]; then
	iface=$1
fi
echo "Start can rx with iface $iface !"


killall cansend
killall candump
candump $iface > can_rx_result &


while true
do
	time1=$(date +%s)
	while true
	do
		result=$(cat can_rx_result | grep "00 11 22 33 44 55 66 77")
		if [[ -n "$result" ]]; then
			cat can_rx_result
			echo $(date +%T.%3N): $iface receive can packet!!
			echo ""
			rx_err_cnt=0
			break
		else
			time2=$(date +%s)
			diff_time=$(($time2 - $time1))
			if [[ $diff_time -ge 2 ]]; then
				((rx_err_cnt+=1))
				echo $(date +%T.%3N): $iface not receive can packet, keep listening!!
				echo ""
				break
			fi
			sleep 0.1
		fi
	done

	echo "" > can_rx_result
	echo $(date +%T.%3N): $iface send 002#7766554433221100
	cansend $iface 002#7766554433221100

	if [[ $rx_err_cnt -ge 3 ]]; then
		echo "$(date +%T.%3N): can rx continue fail over 5 second, rx_err_cnt=$rx_err_cnt!!"
		exit
	fi
done
