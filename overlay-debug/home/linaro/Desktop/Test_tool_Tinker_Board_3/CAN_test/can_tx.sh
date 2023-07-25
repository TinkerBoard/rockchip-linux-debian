#!/bin/bash

iface=can0
if [[ -n "$1" ]]; then
	iface=$1
fi
echo "Start can tx with iface $iface !"

echo "$(date +%T.%3N): $iface send 0011223344556677"
cansend $iface 001#0011223344556677
candump $iface > can_tx_result &

while [ 1 != 2 ]
do
	result=$(cat can_tx_result | grep "77 66 55 44 33 22 11 00")
	if [[ -n "$result" ]]; then
		cat can_tx_result
		echo $(date +%T.%3N): $iface receive can packet
		sleep 0.1
		echo "" > can_tx_result
		exit
	else
		echo $(date +%T.%3N): $iface not receive can packet, keep listening!!
		sleep 2
	fi
done
