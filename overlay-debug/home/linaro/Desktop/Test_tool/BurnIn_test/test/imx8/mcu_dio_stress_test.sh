#!/bin/bash

logfile=$2

do_err_cnt=0
di_err_cnt=0

while [ 1 != 2 ]
do
	dio_out 3 1 > /dev/null 2>&1
	#dio_out 2 0 > /dev/null 2>&1
	#dio_out 1 0 > /dev/null 2>&1
	#dio_out 0 0 > /dev/null 2>&1
	result=$(dio_out | grep "1 0 0 0")
	if [[ -n "$result" ]]; then
		echo "MCU DO set 1 0 0 0 Pass" | tee -a $logfile
		do_err_cnt=0
	else
		echo "MCU DO set 1 0 0 0 Fail" | tee -a $logfile
		((do_err_cnt+=1))
	fi

	result=$(dio_in | grep "0 1 1 1")
	if [[ -n "$result" ]]; then
		echo "MCU DI get 0 1 1 1 Pass" | tee -a $logfile
		di_err_cnt=0
	else
		echo "MCU DI get 0 1 1 1 Fail" | tee -a $logfile
		((di_err_cnt+=1))
	fi
	echo "" | tee -a $logfile
	#dio_out 3 0 > /dev/null 2>&1
	dio_out 2 1 > /dev/null 2>&1
	#dio_out 1 0 > /dev/null 2>&1
	#dio_out 0 0 > /dev/null 2>&1
	result=$(dio_out | grep "0 1 0 0 ")
	if [[ -n "$result" ]]; then
		echo "MCU DO set 0 1 0 0 Pass" | tee -a $logfile
		do_err_cnt=0
	else
		echo "MCU DO set 0 1 0 0 Fail" | tee -a $logfile
		((do_err_cnt+=1))
	fi

	result=$(dio_in | grep "1 0 1 1")
	if [[ -n "$result" ]]; then
		echo "MCU DI get 1 0 1 1 Pass" | tee -a $logfile
		di_err_cnt=0
	else
		echo "MCU DI get 1 0 1 1 Fail" | tee -a $logfile
		((di_err_cnt+=1))
	fi
	echo "" | tee -a $logfile
	if [[ $do_err_cnt -ge 5 || $di_err_cnt -ge 5 ]]; then
		echo "$(date +'%Y%m%d_%H%M') DIO  continue fail over 5 times, do_err_cnt=$do_err_cnt, di_err_cnt=$di_err_cnt"  | tee -a $logfile
		exit 1
	fi
done