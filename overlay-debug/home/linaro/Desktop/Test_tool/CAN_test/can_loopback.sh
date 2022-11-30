#!/bin/bash

can0_err_cnt=0
can1_err_cnt=0

now="$(date +'%Y%m%d_%H%M')"
logfile="$1/$now"_can.txt

function monitro_can()
{
	killall candump
	rm can0_result
	rm can1_result
	candump can0 > can0_result &
	candump can1 > can1_result &
	sleep 0.1
}

while [ 1 != 2 ]
do
	# can0 -> can1 ------------------------------------------------------------------------------------
	monitro_can
	echo "$(date +%T.%3N): CAN0 send 0011223344556677 to CAN1" | tee $2 $logfile
	cansend can0 001#0011223344556677
	sleep 0.1

	result=$(cat can1_result | grep "00 11 22 33 44 55 66 77")
	if [[ -n "$result" ]]; then
		cat can1_result
		echo $(date +%T.%3N): CAN1 receive packet!! | tee $2 $logfile
		echo "" | tee $2 $logfile
		can1_err_cnt=0
	else
		((can1_err_cnt+=1))
		echo $(date +%T.%3N): CAN1 not receive packet, can1_err_cnt=$can1_err_cnt !!  | tee $2 $logfile
	fi
	# ------------------------------------------------------------------------------------------------


	# can1 -> can0 ------------------------------------------------------------------------------------
	monitor_can
	echo $(date +%T.%3N): CAN1 send 002#7766554433221100 to CAN0  | tee $2 $logfile
	cansend can1 002#7766554433221100
	sleep 0.1

	result=$(cat can0_result | grep "77 66 55 44 33 22 11 00")
	if [[ -n "$result" ]]; then
                cat can0_result
		echo $(date +%T.%3N): CAN0 receive packet!!  | tee $2 $logfile
		echo ""  | tee $2 $logfile
		can0_err_cnt=0
	else
		((can0_err_cnt+=1))
		echo $(date +%T.%3N): CAN0 not receive packet, can0_err_cnt=$can0_err_cnt !!  | tee $2 $logfile
	fi
	# ------------------------------------------------------------------------------------------------

	if [[ $can0_err_cnt -ge 5 || $can1_err_cnt -ge 5 ]]; then
		echo "$(date +%T.%3N): can test continue fail over 5 times, can0_err_cnt=$can0_err_cnt, can1_err_cnt=$can1_err_cnt !!"  | tee $2 $logfile
		exit 1
	fi
done
