#!/bin/bash

if [ $# -ne 4 ]; then
	echo "usage: sudo ./usb_tool_test.sh <u2 port number> <u3 port number> <typeC port number> <test times>"
	exit -1
fi

u2port=$1
u3port=$2
tcport=$3
count=$4

cardCount=$(lsusb|grep "iCreate Technologies"|wc -l)
if [ "$cardCount" != "$u2port" ]; then
	echo "FAIL, connected test card number not equal to u2 port number"
	exit -1
fi

for((i=1; i<=count; i++))
do
	sudo UsbTool /tdc -hc $u2port -sc $u3port -bhc $tcport -bsc $tcport -nu30s 0 -d3f 0 -ccst 1\
		> /var/log/usb_test_card.log

	if [ "$?" == "0" ]; then
		if [ "$i" != "$count" ]; then
			sleep 2
		fi
	else
		echo "FAIL"
		exit -1
	fi
done

echo "PASS"

