#!/bin/bash

#LED TEST for PE1000N
#off: 0, on: 1

ETH0_BRIGHT="/sys/class/leds/eth0-led/brightness"
ETH1_BRIGHT="/sys/class/leds/eth1-led/brightness"
UART0_BRIGHT="/sys/class/leds/uart0-led/brightness"
UART1_BRIGHT="/sys/class/leds/uart1-led/brightness"
CAN_BRIGHT="/sys/class/leds/can-led/brightness"
WIFI_BRIGHT="/sys/class/leds/wifi-led/brightness"
LTE_BRIGHT="/sys/class/leds/lte-led/brightness"

ETH0_TRIG="/sys/class/leds/eth0-led/trigger"
ETH1_TRIG="/sys/class/leds/eth1-led/trigger"
UART0_TRIG="/sys/class/leds/uart0-led/trigger"
UART1_TRIG="/sys/class/leds/uart1-led/trigger"
CAN_TRIG="/sys/class/leds/can-led/trigger"
WIFI_TRIG="/sys/class/leds/wifi-led/trigger"
LTE_TRIG="/sys/class/leds/lte-led/trigger"

disableTrigger() {
    echo "none" > "${ETH0_TRIG}"
    echo "none" > "${ETH1_TRIG}"
    echo "none" > "${UART0_TRIG}"
    echo "none" > "${UART1_TRIG}"
    echo "none" > "${CAN_TRIG}"
    echo "none" > "${WIFI_TRIG}"
    echo "none" > "${LTE_TRIG}"
}

recoverTrigger() {
    echo "eth0"  > "${ETH0_TRIG}"
    echo "eth1"  > "${ETH1_TRIG}"
    echo "uart0" > "${UART0_TRIG}"
    echo "uart1" > "${UART1_TRIG}"
    echo "can"   > "${CAN_TRIG}"
    echo "wifi"  > "${WIFI_TRIG}"
    echo "lte"   > "${LTE_TRIG}"
}

display_help() {
    echo "Usage:"
    echo "    $0 arg1 arg2 arg3 arg4 arg5 arg6 arg7"
    echo "Arguments:"
    echo "    arg1: eth0 led brightness"
    echo "    arg2: eth1 led brightness"
    echo "    arg3: uart0 led brightness"
    echo "    arg4: uart1 led brightness"
    echo "    arg5: can led brightness"
    echo "    arg6: wifi led brightness"
    echo "    arg7: lte led brightness"
    echo "EX:"
    echo "    $0 0 0 0 0 0 0 0 : Disable all brightness"
    echo "    $0 1 1 1 1 1 1 1 : Enable all brightness"
    echo ""
    echo "Note:"
    echo "    Disable all function triggers first when execute this script"
    echo "    $0 -r : recover all trigger states"
    exit 1
}

if [ "$1" == "-r" ]; then
    echo "Recover all trigger states"
    recoverTrigger
    exit 0
fi

ETH0=$1
ETH1=$2
UART0=$3
UART1=$4
CAN=$5
WIFI=$6
LTE=$7

disableTrigger

#ETH0
if [ "$ETH0" == "0" ]; then
    echo 0 > "${ETH0_BRIGHT}"
elif [ "$ETH0" == "1" ]; then
    echo 1 > "${ETH0_BRIGHT}"
else
    echo "invalid value for eth0 led"
    display_help
fi

#ETH1
if [ "$ETH1" == "0" ]; then
    echo 0 > "${ETH1_BRIGHT}"
elif [ "$ETH1" == "1" ]; then
    echo 1 > "${ETH1_BRIGHT}"
else
    echo "invalid value for eth1 led"
    display_help
fi

#UART0
if [ "$UART0" == "0" ]; then
    echo 0 > "${UART0_BRIGHT}"
elif [ "$UART0" == "1" ]; then
    echo 1 > "${UART0_BRIGHT}"
else
    echo "invalid value for uart0 led"
    display_help
fi

#UART1
if [ "$UART1" == "0" ]; then
    echo 0 > "${UART1_BRIGHT}"
elif [ "$UART1" == "1" ]; then
    echo 1 > "${UART1_BRIGHT}"
else
    echo "invalid value for uart1 led"
    display_help
fi

#CAN
if [ "$CAN" == "0" ]; then
    echo 0 > "${CAN_BRIGHT}"
elif [ "$CAN" == "1" ]; then
    echo 1 > "${CAN_BRIGHT}"
else
    echo "invalid value for can led"
    display_help
fi

#WIFI
if [ "$WIFI" == "0" ]; then
    echo 0 > "${WIFI_BRIGHT}"
elif [ "$WIFI" == "1" ]; then
    echo 1 > "${WIFI_BRIGHT}"
else
    echo "invalid value for wifi led"
    display_help
fi

#LTE
if [ "$LTE" == "0" ]; then
    echo 0 > "${LTE_BRIGHT}"
elif [ "$LTE" == "1" ]; then
    echo 1 > "${LTE_BRIGHT}"
else
    echo "invalid value for lte led"
    display_help
fi

exit 0


