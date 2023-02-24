#!/bin/bash

interface_wifi=""
scan_ap=""
retry_scan_ap=""
AP_NAME=$1
AP_PW=$2

interface_wifi=$(/sbin/ifconfig | egrep "wlan0|wlp1s0" | awk '{print$1}' | awk '{ gsub(/:/,""); print }')

if [ "$interface_wifi" != "" ]; then
    sudo nmcli connection delete $AP_NAME > /dev/null 2>$2
    sudo nmcli dev wifi rescan
    sleep 3
    scan_ap=$(nmcli dev wifi | grep -w "${AP_NAME}" | awk '{print$1}')

    if [ "$scan_ap" != "$AP_NAME" ]; then
        sleep 15
        sudo nmcli dev wifi rescan
        retry_scan_ap=$(nmcli dev wifi | grep -w "${AP_NAME}" | awk '{print$2}')
        if [ "$retry_scan_ap" != "$AP_NAME" ]; then
            echo "FAIL, ret=-2"
            exit
        fi
    fi

    output=$(sudo nmcli d wifi connect ${AP_NAME} password ${AP_PW})
    if [ "$output" == "Error" ]; then
        echo "FAIL, ret=-3"
        exit
    fi
    sleep 1

    GW=$(/sbin/route -n | grep "${interface_wifi}" | grep UG | awk '{printf $2}')
    echo "GW=$GW"
    if [[ -n "$GW" ]]; then
        sudo ping $GW -w 100 -c 1 > /dev/null 2>&1
	if [ ! $? -eq 0 ]; then
		echo "FAIL, ret=-4"
		exit
	fi
    else
        echo "FAIL, ret=-4"
	exit
    fi

    if [ -f "/proc/net/rtl88x2ce/${interface_wifi}/rx_info_msg" ]; then
        RSSI1=$(cat /proc/net/rtl88x2ce/${interface_wifi}/rx_info_msg | grep "Unicast" -A4 | grep "RF_PATH_0" | awk -F"[ ,:()]" '{print $3}')
        RSSI2=$(cat /proc/net/rtl88x2ce/${interface_wifi}/rx_info_msg | grep "Unicast" -A4 | grep "RF_PATH_1" | awk -F"[ ,:()]" '{print $3}')
    else
        /sbin/iwpriv wlan0 txrx_fw_stats 3
        RSSI1=$(dmesg | grep RSSI | tail -3 | grep "Chain 0" | awk {'print $9'} | awk -F ')' {'print $1'})
        RSSI2=$(dmesg | grep RSSI | tail -3 | grep "Chain 1" | awk {'print $9'} | awk -F ')' {'print $1'})
        RSSI1=$[ $RSSI1 - 96 ]
        RSSI2=$[ $RSSI2 - 96 ]
    fi
    RSSI=$(/usr/sbin/iw dev ${interface_wifi} link | grep signal | awk '{print$2}')

    sudo nmcli connection delete $AP_NAME > /dev/null 2>&1 &
    if [ "$3" == "all" ]; then
        echo "RSSI= ${RSSI} ${RSSI1} ${RSSI2}"
    else
        echo "RSSI= ${RSSI1} ${RSSI2}"
    fi
else
    echo "FAIL, ret=-1"
fi
