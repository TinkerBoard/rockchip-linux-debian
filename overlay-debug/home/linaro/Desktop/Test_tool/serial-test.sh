#!/bin/bash
com1to2=0
com2to1=0

if [[ -z "$1" || -z "$2" ]]; then
	echo "Need port name parameter."
	exit 1
fi

com1to2=`/home/asus/Desktop/Test_tool/BurnIn_test/test/serial-test -p $1 $2 -1`
sleep 1
com2to1=`/home/asus/Desktop/Test_tool/BurnIn_test/test/serial-test -p $1 $2 -2`
if [ "$com1to2" == "PASS" -a "$com2to1" == "PASS" ]
then
	echo "PASS"
else
	echo "============FAIL============"
	echo "com1to2 = $com1to2"
	echo "com2to1 = $com2to1"
	echo "============================"
fi
