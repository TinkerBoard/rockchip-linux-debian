#!/bin/bash
err_cnt=0
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
port=$1
logfile=$2
echo "Start COM1 loopback test" | tee -a $logfile
while [ 1 != 2 ]
do
	$SCRIPTPATH/linux-serial-test -s -e -p $port 115200 | tee -a $logfile.tmp
	tr '\r' '\n' < $logfile.tmp > $logfile.tmp2
	loop=`cat $logfile.tmp2 | grep loopback | wc -l`
	if [[ $loop -ge 2 ]]; then
		err_cnt=1
	else
		((err_cnt+=1))
	fi
	cat $logfile.tmp2 | tee -a $logfile > /dev/null
	echo "" | tee -a $logfile
	echo "continue error cnt = $err_cnt" | tee -a $logfile
	rm $logfile.tmp*
	if [[ $err_cnt -ge 3 ]]; then
		exit 1
	fi
	sleep 1
done
