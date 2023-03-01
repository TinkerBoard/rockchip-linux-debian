#!/bin/bash -e

PIN="$1"

echo out > /sys/class/gpio/gpio150/direction
echo 1 > /sys/class/gpio/gpio150/value

ADC11=`cat /sys/bus/iio/devices/iio\:device0/in_voltage6_raw`
ADC12=`cat /sys/bus/iio/devices/iio\:device0/in_voltage7_raw`

MAX=559
MIN=505


if [ $PIN -eq 6 ]
then
	if [ $ADC11 -le $MAX ] && [ $ADC11 -ge $MIN ]
	then
        	echo "PASS"
	else
        	echo "FAIL"
	fi
fi

if [ $PIN -eq 7 ]
then
	if [ $ADC12 -le $MAX ] && [ $ADC12 -ge $MIN ]
	then
       		echo "PASS"
	else
        	echo "FAIL"
	fi
fi

