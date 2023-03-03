#!/bin/bash

if [ $# -ne 3 ]; then
	echo "usage: sudo ./usb_tool_test.sh <u2 port number> <u3 port number> <test times>"
	exit -1
fi

u2port=$1
u3port=$2
count=$3

cardCount=$(lsusb|grep "iCreate Technologies"|wc -l)
if [ "$cardCount" != "$u2port" ]; then
	echo "FAIL, connected test card number not equal to u2 port number"
	exit -1
fi

for((i=1; i<=count; i++))
do
	sudo UsbTool /tdc -hc $u2port -lc $u2port -fc $u2port -sc $u3port -nu30s 0 -d3f 0 -ccst 1\
		> /var/log/usb_test_card.log

	if [ "$?" == "0" ]; then
		if [ "$i" != "$count" ]; then
			sleep 5
		fi
	else
		grep USB31S /var/log/usb_test_card.log|grep Fail > /dev/null 2>&1
		if [ "$?" == "0" ]; then
			echo "FAIL, USB31S test fail"
		fi
		grep USB31H /var/log/usb_test_card.log|grep Fail > /dev/null 2>&1
		if [ "$?" == "0" ]; then
			echo "FAIL, USB31H test fail"
		fi
		grep USB30S /var/log/usb_test_card.log|grep Fail > /dev/null 2>&1
		if [ "$?" == "0" ]; then
			echo "FAIL, USB30S test fail"
		fi
		grep USB30H /var/log/usb_test_card.log|grep Pass > /dev/null 2>&1
		if [ "$?" == "1" ]; then
			echo "FAIL, USB30H test fail"
		fi
		exit -1
	fi
done

echo "PASS"

