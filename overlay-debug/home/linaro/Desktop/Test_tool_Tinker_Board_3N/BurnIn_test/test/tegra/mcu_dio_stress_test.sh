#!/bin/bash

logfile=$2

do_err_cnt=0
di_err_cnt=0
start_sec=$(date +%s)
start_use_mem=`free -m | grep Mem | awk '{print $3 }'`
while [ 1 != 2 ]
do
	dio_out 3 1 > /dev/null 2>&1
	dio_out 2 0 > /dev/null 2>&1
	dio_out 1 1 > /dev/null 2>&1
	dio_out 0 0 > /dev/null 2>&1
	result=$(dio_out | grep "1 0 1 0")
	if [[ -n "$result" ]]; then
		echo "MCU DO set 1 0 1 0 Pass" | tee -a $logfile
		do_err_cnt=0
	else
		((do_err_cnt+=1))
		echo "MCU DO set 1 0 1 0 Fail($do_err_cnt)" | tee -a $logfile
	fi
	sleep 0.2
	result=$(dio_in | grep "0 1 0 1")
	echo "dio_in $result"
	if [[ -n "$result" ]]; then
		echo "MCU DI get 0 1 0 1 Pass" | tee -a $logfile
		di_err_cnt=0
	else
		((di_err_cnt+=1))
		echo "MCU DI get 0 1 0 1 Fail($di_err_cnt)" | tee -a $logfile
	fi
	echo "" | tee -a $logfile
	dio_out 3 0 > /dev/null 2>&1
	dio_out 2 1 > /dev/null 2>&1
	dio_out 1 0 > /dev/null 2>&1
	dio_out 0 1 > /dev/null 2>&1
	result=$(dio_out | grep "0 1 0 1")
	if [[ -n "$result" ]]; then
		echo "MCU DO set 0 1 0 1 Pass" | tee -a $logfile
		do_err_cnt=0
	else
		((do_err_cnt+=1))
		echo "MCU DO set 0 1 0 1 Fail($do_err_cnt)" | tee -a $logfile
		
	fi
	sleep 0.2
	result=$(dio_in | grep "1 0 1 0")
	echo "dio_in $result"
	if [[ -n "$result" ]]; then
		echo "MCU DI get 1 0 1 0 Pass" | tee -a $logfile
		di_err_cnt=0
	else
		((di_err_cnt+=1))
		echo "MCU DI get 1 0 1 0 Fail($di_err_cnt)" | tee -a $logfile
	fi
	echo "" | tee -a $logfile
	if [[ $do_err_cnt -ge 5 || $di_err_cnt -ge 5 ]]; then
		echo "$(date +'%Y%m%d_%H%M') DIO  continue fail over 5 times, do_err_cnt=$do_err_cnt, di_err_cnt=$di_err_cnt"  | tee -a $logfile
		exit 1
	fi
	sleep 60
	end_use_mem=`free -m | grep Mem | awk '{print $3 }'`
	end_sec=$(date +%s)
	diff=$(( $end_sec - $start_sec ))
	diff_mem=$(( $end_use_mem - $start_use_mem ))
	echo "spend $diff sec and memory use more $diff_mem Mbyte" | tee -a $logfile
done