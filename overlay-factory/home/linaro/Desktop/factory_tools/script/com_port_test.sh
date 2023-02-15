#!/bin/bash
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

PROJECT="Tinker3"
version=1.0.0

COM1to2_result=0
COM2to1_result=0
COM1to1_result=0
COM2to2=0

BINARY_PATH=$SCRIPTPATH'/../bin'
TEST_BINARY_PATH=$BINARY_PATH'/com_port_test'
SWITCH_SCRIPT_PATH=$SCRIPTPATH'/switch_com3_protocol.sh'

select_test_item()
{
	echo "============================================"
	echo "     $PROJECT COM Port Test v_$version"
	echo "============================================"
	echo
	echo " 1. COM1 RS232 self test"
	echo " 2. COM2 RS232 self test"
	echo " 3. COM1 RS232, COM2 RS232 loop test"
    echo " 4. COM1 RS232, COM2 RS232 loop test with flow control"
	echo " 5. COM1 RS232, COM3 RS232 loop test"
	echo " 6. COM1 RS232, COM3 RS422 loop test"
	echo " 7. COM1 RS232, COM3 RS485 loop test"

	read -p "Select test case: " test_item
}

select_test_item
echo

case $test_item in
	1)
		COM1to1_result=`$TEST_BINARY_PATH -p /dev/ttyS0 none -3`
        ;;
	2)
		COM1to1_result=`$TEST_BINARY_PATH -p /dev/ttyS8 none -3`
        ;;
	3)
		COM1to2_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS8 -1`
        sleep 1
        COM2to1_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS8 -2`
        ;;
	4)
		COM1to2_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS8 -1 -f`
        COM2to1_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS8 -2 -f`
        ;;
	5)
        . $SWITCH_SCRIPT_PATH 232
		COM1to2_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS3 -1`
        sleep 1
        COM2to1_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS3 -2`
        ;;
	6)
        . $SWITCH_SCRIPT_PATH 422
		COM1to2_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS3 -1`
        sleep 1
        COM2to1_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS3 -2`
        ;;
	7)
        . $SWITCH_SCRIPT_PATH 485
		COM1to2_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS3 -1`
        sleep 1
        COM2to1_result=`$TEST_BINARY_PATH -p /dev/ttyS0 /dev/ttyS3 -2`
        ;;
	*)
        echo "Select error."
		;;
esac

if [ "$test_item" == "1" -o "$test_item" == "2" ]
then
    if [ "$COM1to1_result" == "PASS" ]
    then
        echo "TEST PASS"
    else
        echo "=============FAIL============="
        echo "Test result : $COM1to1_result"
        echo "=============================="
    fi
else
    if [ "$COM1to2_result" == "PASS" -a "$COM2to1_result" == "PASS" ]
    then
        echo "TEST PASS"
    else
        echo "=============FAIL============="
        echo "Test result 1 : $COM1to2_result"
        echo "Test result 2 : $COM2to1_result"
        echo "=============================="

    fi
fi
