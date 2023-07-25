#!/bin/bash

sudo /sbin/ip link set can0 up type can bitrate 125000

killall cansend
killall candump
/usr/bin/cansend can0 001#0011223344556677
/usr/bin/candump can0 > can_result &

counter=0
while [ $counter -le 30 ]
do
    result=$(cat can_result | grep "77 66 55 44 33 22 11 00")
    if [[ -n "$result" ]]; then
        cat can_result
        echo receive can packet, pass
        echo "" > can_result
        break
    else
        sleep 5
        counter=`expr $counter + 5`
    fi
done
