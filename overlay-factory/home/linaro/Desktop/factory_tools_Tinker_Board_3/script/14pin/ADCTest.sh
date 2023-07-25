#!/bin/bash -e

ADC11=`cat /sys/bus/iio/devices/iio\:device0/in_voltage6_raw`
ADC12=`cat /sys/bus/iio/devices/iio\:device0/in_voltage7_raw`

echo "ADC6: $ADC11"
echo "ADC7: $ADC12"