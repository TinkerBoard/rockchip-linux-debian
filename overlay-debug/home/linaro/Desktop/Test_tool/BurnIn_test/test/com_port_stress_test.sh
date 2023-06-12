#!/bin/bash
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
COM1to2=0
COM2to1=0
COM1to1=0
protocol=0
flow_control=0
logfile=0

pass_cnt=0
fail_cnt=0

BINARY_PATH=$SCRIPTPATH
TEST_BINARY_PATH=$BINARY_PATH'/com_port_test'
SWITCH_SCRIPT_PATH=$SCRIPTPATH'/switch_com3_protocol.sh'

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

if [ $# == 3 ]; then
	COM1=$1
    COM2="none"
    flow_control=$2
    logfile=$3
	testmode="one_port"
elif [ $# == 5 ]; then
	COM1=$1
	COM2=$2
    protocol=$3
    flow_control=$4
    logfile=$5
	testmode="two_port"
else
	echo "Wrong parameter amount, please check the following format."
	echo "1. comport_test.sh [COM1] [COM2] [PROTOCOL] [FLOW_CONTROL]"
	echo "2. comport_test.sh [COM1] [FLOW_CONTROL]"
	exit 1
fi

TEST_SCRIPT=$TEST_BINARY_PATH' -p '$COM1' '$COM2

while [ 1 != 2 ]
do

    if [ "$flow_control" == "1" ]; then
        TEST_SCRIPT="$TEST_BINARY_PATH -p $COM1 $COM2 -f"
    fi

    if [ "$testmode" == "one_port" ]; then
        COM1to1=`$TEST_SCRIPT -3`
        if [ "$COM1to1" == "PASS" ]
        then
			log "TEST PASS"
			((pass_cnt+=1))
			log "pass_cnt=$pass_cnt"
		else
			log "Test result : $COM1to1"
			((fail_cnt+=1))
			log "fail_cnt=$fail_cnt"
		fi
    elif [ "$testmode" == "two_port" ]; then
        if [ "$protocol" == "0" ]; then
            :
        elif [ "$protocol" == "232" ]; then
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
			log "TEST PASS"
			((pass_cnt+=1))
			log "pass_cnt=$pass_cnt"
		else
			log "Test result 1 : $COM1to2"
            log "Test result 2 : $COM2to1"
			((fail_cnt+=1))
			log "fail_cnt=$fail_cnt"
		fi
    else
        echo "Wrong testmode option, please check the following information."
        exit 1
    fi
    
    if [ "$fail_cnt" -ge 6  ]; then
		log "uart pass_cnt = $pass_cnt fail_cnt = $fail_cnt"
		exit
	fi

done

