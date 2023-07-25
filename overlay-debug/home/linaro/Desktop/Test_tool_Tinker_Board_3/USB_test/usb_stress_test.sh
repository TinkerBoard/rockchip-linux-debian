#!/bin/bash

if [ $# -ne 2 ]; then
	echo "usage：sudo ./usb_stress_test.sh <u2 port count> <u3 port count>"
	exit -1
fi

u2port=$1
u3port=$2

for((i=1; i<=60000; i++))
do
	echo "Test "$i
	sudo UsbTool /tdc -hc $u2port -lc $u2port -fc $u2port -sc $u3port -nu30s 0 -d3f 0 -ccst 1

if [ "$?" == "0" ]; then
	echo "Pass"
	sleep 10
else
	echo "Fail"
	exit -1
fi

done

