#!/bin/bash

iface=can0
tx_err_cnt=0
if [[ -n "$1" ]]; then
	iface=$1
fi
echo "Start can tx with iface $iface !"

echo $(date +%T.%3N): $iface send 001#0011223344556677
cansend $iface 001#0011223344556677
candump $iface > can_tx_result &

while true
do
	time1=$(date +%s)
	while true
	do
		result=$(cat can_tx_result | grep "77 66 55 44 33 22 11 00")
		if [[ -n "$result" ]]; then
			cat can_tx_result
			echo $(date +%T.%3N): $iface receive can packet
			echo ""
			tx_err_cnt=0
			break
		else
			time2=$(date +%s)
			diff_time=$(($time2 - $time1))
			if [[ $diff_time -ge 2 ]]; then
				((tx_err_cnt+=1))
				echo $(date +%T.%3N): $iface not receive can packet, keep listening!!
				echo ""
				break
			fi
			sleep 0.1
		fi
	done

	echo "" > can_tx_result
	echo $(date +%T.%3N): $iface send 001#0011223344556677
	cansend $iface 001#0011223344556677

	if [[ $tx_err_cnt -ge 3 ]]; then
		echo "$(date +%T.%3N): can tx continue fail over 5 second, tx_err_cnt=$tx_err_cnt!!"
		exit
	fi
done
