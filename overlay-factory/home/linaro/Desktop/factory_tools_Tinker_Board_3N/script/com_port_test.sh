#!/bin/bash
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
COM1to2=0
COM2to1=0
COM1to1=0
protocol=0
flow_control=0

BINARY_PATH=$SCRIPTPATH'/../bin'
TEST_BINARY_PATH=$BINARY_PATH'/com_port_test'
SWITCH_SCRIPT_PATH=$SCRIPTPATH'/switch_com3_protocol.sh'

if [ $# == 1 ]; then
    COM1=$1
    COM2="none"
    testmode="one_port"
elif [ $# == 4 ]; then
    COM1=$1
    COM2=$2
    protocol=$3
    flow_control=$4
    testmode="two_port"
else
    echo "Wrong parameter amount, please check the following format."
    echo "1. comport_test.sh [COM1] [COM2] [PROTOCOL] [FLOW_CONTROL]"
    echo "2. comport_test.sh [COM1]"
    exit 1
fi

TEST_SCRIPT=$TEST_BINARY_PATH' -p '$COM1' '$COM2

if [ "$flow_control" == "1" ]; then
    TEST_SCRIPT="$TEST_BINARY_PATH -p $COM1 $COM2 -f"
fi

if [ "$testmode" == "one_port" ]; then
    COM1to1=`$TEST_SCRIPT -3`
    if [ "$COM1to1" == "PASS" ]
    then
        echo "TEST PASS"
    else
        echo "=============FAIL============="
        echo "Test result : $COM1to1"
        echo "=============================="
    fi
elif [ "$testmode" == "two_port" ]; then
    if [ "$protocol" == "232" ]; then
        . $SWITCH_SCRIPT_PATH 232
    elif [ "$protocol" == "422" ]; then
        . $SWITCH_SCRIPT_PATH 422
    elif [ "$protocol" == "485" ]; then
        . $SWITCH_SCRIPT_PATH 485
    fi

    COM1to2=`$TEST_SCRIPT -1`
    sleep 1
    COM2to1=`$TEST_SCRIPT -2`

    if [ "$COM1to2" == "PASS" -a "$COM2to1" == "PASS" ]
    then
        echo "TEST PASS"
    else
        echo "=============FAIL============="
        echo "Test result 1 : $COM1to2"
        echo "Test result 2 : $COM2to1"
        echo "=============================="
    fi
else
    echo "Wrong testmode option, please check the following information."
    exit 1
fi

