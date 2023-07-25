#!/bin/bash

logfile=$2
mode=232
COM1=3
COM2=4
uart_err_cnt=0

comport_test -c $COM1 -s 0 > /dev/null 2>&1
comport_test -c $COM1 -s 1 -m $mode > /dev/null 2>&1
comport_test -c $COM2 -s 0 > /dev/null 2>&1
comport_test -c $COM2 -s 1 -m $mode > /dev/null 2>&1

while [ 1 != 2 ]
do

	echo "COM3 write" | tee -a $logfile
	comport_test -c $COM1 -w "1234321 " | tee -a $logfile
	sleep 0.1
	result=$(comport_test -c $COM2 -r | tee -a $logfile | grep "1234321")
	if [[ -n "$result" ]]; then
		echo "COM4 read Pass" | tee -a $logfile
		uart_err_cnt=0
	else
		echo "COM4 read Fail" | tee -a $logfile
		((uart_err_cnt+=1))
	fi
	echo "" | tee -a $logfile
	echo "COM4 write" | tee -a $logfile
	comport_test -c $COM2 -w "4321234 " | tee -a $logfile
	sleep 0.1
	result=$(comport_test -c $COM1 -r | tee -a $logfile | grep "4321234")
	if [[ -n "$result" ]]; then
		echo "COM3 read Pass" | tee -a $logfile
		uart_err_cnt=0
	else
		echo "COM3 read Fail" | tee -a $logfile
		((uart_err_cnt+=1))
	fi
	echo "" | tee -a $logfile
	if [[ $uart_err_cnt -ge 5 ]]; then
		echo "$(date +'%Y%m%d_%H%M') UART continue fail over 5 times, uart_err_cnt=$uart_err_cnt" | tee -a $logfile
		comport_test -c $COM1 -s 0 > /dev/null 2>&1
		comport_test -c $COM2 -s 0 > /dev/null 2>&1
		exit 1
	fi
done
