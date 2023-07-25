#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Need protocol parameter."
    echo "switch_uart_protocol.sh [COM3_protocol]"
	exit 1
fi
COM=$1

#R_DIS
if [[ ! -d /sys/class/gpio/gpio6/ ]]; then
    echo "6" > /sys/class/gpio/export
    echo "out" > /sys/class/gpio/gpio6/direction
fi

#M0
if [[ ! -d /sys/class/gpio/gpio32/ ]]; then
    echo "32" > /sys/class/gpio/export
    echo "out" > /sys/class/gpio/gpio32/direction
fi

#M1
if [[ ! -d /sys/class/gpio/gpio33/ ]]; then
    echo "33" > /sys/class/gpio/export
    echo "out" > /sys/class/gpio/gpio33/direction
fi

if [ "$COM" == "232" ]; then
    echo "1" > /sys/class/gpio/gpio6/value
    echo "0" > /sys/class/gpio/gpio32/value
    echo "0" > /sys/class/gpio/gpio33/value
elif [ "$COM" == "422" ]; then
    echo "0" > /sys/class/gpio/gpio6/value
    echo "0" > /sys/class/gpio/gpio32/value
    echo "1" > /sys/class/gpio/gpio33/value
elif [ "$COM" == "485" ]; then
    echo "0" > /sys/class/gpio/gpio6/value
    echo "1" > /sys/class/gpio/gpio32/value
    echo "0" > /sys/class/gpio/gpio33/value
else
    echo "Invalid com port protocol: $COM"
fi

echo "Set COM3 to $COM"