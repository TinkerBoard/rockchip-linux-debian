#!/bin/bash

process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip4/export")
process=$(sudo su -c "echo 1000000000 > /sys/class/pwm/pwmchip4/pwm0/period")
process=$(sudo su -c "echo 800000000 > /sys/class/pwm/pwmchip4/pwm0/duty_cycle")
process=$(sudo su -c "echo "normal" > /sys/class/pwm/pwmchip4/pwm0/polarity")
process=$(sudo su -c "echo 1 > /sys/class/pwm/pwmchip4/pwm0/enable")
voltage_raw=$(cat /sys/bus/iio/devices/iio:device0/in_voltage7_raw)
voltage=$(($voltage_raw*1800/1023))

result1=""
result2=""

while [ "1" -ne "2" ]
do
	sleep 2
	result1=$(cat /sys/kernel/ir_sysfs/getperiod)
	process=$(sudo su -c "echo 600000000 > /sys/class/pwm/pwmchip4/pwm0/duty_cycle")
	sleep 2
	result2=$(cat /sys/kernel/ir_sysfs/getperiod)

	if [ "$result1" == "8" ] && [ "$result2" == "6" ] && [ "1568" -lt "$voltage" ] && [ "1733" -gt "$voltage" ]; then
		process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip4/pwm0/enable")
		process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip4/unexport")
		echo "PASS"
		exit
	else
		process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip4/pwm0/enable")
		process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip4/unexport")
		echo "FAIL"
		exit
	fi
done