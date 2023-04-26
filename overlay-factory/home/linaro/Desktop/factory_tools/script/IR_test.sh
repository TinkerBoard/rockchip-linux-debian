#!/bin/bash

process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip5/export")
process=$(sudo su -c "echo 1000000000 > /sys/class/pwm/pwmchip5/pwm0/period")
process=$(sudo su -c "echo 800000000 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle")
process=$(sudo su -c "echo "normal" > /sys/class/pwm/pwmchip5/pwm0/polarity")
process=$(sudo su -c "echo 1 > /sys/class/pwm/pwmchip5/pwm0/enable")

result1=""
result2=""

while [ "1" -ne "2" ]
do
	sleep 2
	result1=$(cat /sys/kernel/ir_sysfs/getperiod)
	process=$(sudo su -c "echo 600000000 > /sys/class/pwm/pwmchip5/pwm0/duty_cycle")
	sleep 2
	result2=$(cat /sys/kernel/ir_sysfs/getperiod)

	if [ "$result1" == "8" ] && [ "$result2" == "6" ]; then
		process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip5/pwm0/enable")
		process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip5/unexport")
		echo "PASS"
		exit
	else
		process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip5/pwm0/enable")
		process=$(sudo su -c "echo 0 > /sys/class/pwm/pwmchip5/unexport")
		echo "FAIL"
		exit
	fi
done