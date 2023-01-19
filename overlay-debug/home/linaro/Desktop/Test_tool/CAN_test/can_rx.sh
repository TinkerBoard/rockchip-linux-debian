#!/bin/bash

iface=can0
if [[ -n "$1" ]]; then
	iface=$1
fi
echo "Start can rx with iface $iface !"


killall cansend
killall candump
candump $iface > can_rx_result &


while [ 1 != 2 ]
do
	result=$(cat can_rx_result | grep "00 11 22 33 44 55 66 77")
	if [[ -n "$result" ]]; then
		cat can_rx_result
		echo $(date +%T.%3N): $iface receive can packet, send 002#7766554433221100
		cansend $iface 002#7766554433221100
		sleep 0.1
		echo "" > can_rx_result
		exit
	else
		echo $(date +%T.%3N): $iface not receive can packet, keep listening!!
		sleep 2
	fi
done
