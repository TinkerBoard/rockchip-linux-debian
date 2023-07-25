#!/bin/bash

MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')

echo performance > /sys/class/devfreq/dmc/governor
DRAM_CLOCK=$(cat /sys/class/devfreq/dmc/cur_freq 2> /dev/null)

if [ -z $DRAM_CLOCK ]; then
    echo "FAIL"
else
    echo "$MEM_TOTAL,$DRAM_CLOCK"
fi
