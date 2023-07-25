#!/bin/bash
com1to2=0
com2to1=0
logfile=$4
SOC_TYPE=$5
err_cnt=0

if [[ -z "$1" || -z "$2" ]]; then
	echo "$(date +'%Y%m%d_%H%M') Need port name parameter." | tee -a $logfile
        exit 1
fi
while [ 1 != 2 ]
do
	if [ $SOC_TYPE == "rockchip" ]; then
		com1to2=`/home/linaro/Desktop/Test_tool/BurnIn_test/test/serial-test -p $1 $2 -1`
		sleep 1
		com2to1=`/home/linaro/Desktop/Test_tool/BurnIn_test/test/serial-test -p $1 $2 -2`
	else
		com1to2=`/home/asus/Desktop/Test_tool/BurnIn_test/test/serial-test -p $1 $2 -1`
		sleep 1
		com2to1=`/home/asus/Desktop/Test_tool/BurnIn_test/test/serial-test -p $1 $2 -2`	
	fi
	if [ "$com1to2" == "PASS" -a "$com2to1" == "PASS" ]
	then
		echo "PASS" | tee -a $logfile
		err_cnt=0
	else
		echo "============FAIL============" | tee -a $logfile
		echo "com1to2 = $com1to2" | tee -a $logfile
		echo "com2to1 = $com2to1" | tee -a $logfile
		echo "============================" | tee -a $logfile
		((err_cnt+=1))
	fi

	if [ $err_cnt -ge 5 ] 
	then
    		echo "$(date +'%Y%m%d_%H%M') uart test continue fail over 5 times"  | tee -a $logfile
	exit 1
	fi
done
