#!/bin/bash -e

Output="$1"
Input="$2"

#echo "output=${Output} => input=${Input}"
#set output low
echo in > /sys/class/gpio/gpio"${Input}"/direction
echo out > /sys/class/gpio/gpio"${Output}"/direction
echo 0 > /sys/class/gpio/gpio"${Output}"/value
#echo "=======Low========"
#echo "pin${Output}(output)"

sleep 1
FromStatusL=`cat /sys/class/gpio/gpio"${Output}"/value`
#set input
#echo in > /sys/class/gpio/gpio"${Input}"/direction
ToStatusL=`cat /sys/class/gpio/gpio"${Input}"/value`

#sleep 1

#echo "write 0 => read FromStatusL=$FromStatusL"
#echo "write 0 => read ToStatusL=$ToStatusL"

#set output high
echo out > /sys/class/gpio/gpio"${Output}"/direction
echo 1 > /sys/class/gpio/gpio"${Output}"/value
#echo "=======High========"
#echo "pin${Output}(output)"
FromStatusH=`cat /sys/class/gpio/gpio"${Output}"/value`

#get input
ToStatusH=`cat /sys/class/gpio/gpio"${Input}"/value`


#echo "write 1 => read FromStatusH=$FromStatusH"
#echo "write 1 => read ToStatusH=$ToStatusH"

if [ $FromStatusL -eq 0 ] && [ $ToStatusL -eq 0 ] && [ $FromStatusH -eq 1 ] && [ $ToStatusH -eq 1 ]; then
    echo "PASS"
else
    echo "FAIL"
fi

