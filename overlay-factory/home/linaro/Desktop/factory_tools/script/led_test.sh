#!/bin/bash

#LED TEST for Tinker Board 3

ACT=$1
RSV=$2

ACT_LED_TRIGGER="/sys/class/leds/act-led/trigger"
ACT_LED_BRIGHT="/sys/class/leds/act-led/brightness"
RSV_LED_BRIGHT="/sys/class/leds/rsv-led/brightness"

echo "none" > $ACT_LED_TRIGGER

#ACT
if [ "$ACT" == "0" ]; then
    echo 0 > "${ACT_LED_BRIGHT}"
elif [ "$ACT" == "1" ]; then
    echo 1 > "${ACT_LED_BRIGHT}"
else
    echo "invalid value for emmc led"
    exit 1
fi

#RSV
if [ "$RSV" == "0" ]; then
    echo 0 > "${RSV_LED_BRIGHT}"
elif [ "$RSV" == "1" ]; then
    echo 1 > "${RSV_LED_BRIGHT}"
else
    echo "invalid value for reserved led"
    exit 1
fi

exit 0


