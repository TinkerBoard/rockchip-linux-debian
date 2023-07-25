#!/bin/bash


set_gpio_input() {
	if [ -d "/sys/class/gpio/gpio$1/" ]; then
		echo $1 > /sys/class/gpio/unexport
		sleep 0.5
	fi
	echo $1 > /sys/class/gpio/export
	sleep 0.5
	echo in > /sys/class/gpio/gpio$1/direction
	sleep 0.5

}

set_gpio_output() {

        if [ -d "/sys/class/gpio/gpio$1/" ]; then
                echo $1 > /sys/class/gpio/unexport
        fi
        echo $1 > /sys/class/gpio/export
	sleep 0.5
        echo out > /sys/class/gpio/gpio$1/direction
	sleep 0.5
}


# Test 24 input 25 output
set_gpio_input 24
set_gpio_output 25
echo 1 > /sys/class/gpio/gpio25/value
sleep 0.5
result=$(cat /sys/class/gpio/gpio24/value)
if [ "$result" == "0" ]; then
	echo "FAIL"
	exit
fi

echo 0 > /sys/class/gpio/gpio25/value
sleep 0.5
result=$(cat /sys/class/gpio/gpio24/value)
if [ "$result" == "1" ]; then
        echo "FAIL"
        exit
fi

# Test 25 input 24 output
set_gpio_input 25
set_gpio_output 24
echo 1 > /sys/class/gpio/gpio24/value
sleep 0.5
result=$(cat /sys/class/gpio/gpio25/value)
if [ "$result" == "0" ]; then
        echo "FAIL"
        exit
fi

echo 0 > /sys/class/gpio/gpio24/value
sleep 0.5
result=$(cat /sys/class/gpio/gpio25/value)
if [ "$result" == "1" ]; then
        echo "FAIL"
        exit
else
        echo "PASS"
        exit
fi
