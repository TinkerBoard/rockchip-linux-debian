#!/bin/bash
SOC_TYPE=$3
logfile=$2
bt_interface=hci0

echo "bt_interface: $bt_interface"

log()
{
        echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

sleep 3
pass_cnt=0
fail_cnt=0
while [ 1 != 2 ]
do
	bt=$(hciconfig | grep $bt_interface)

        if [ ! -z "$bt" ]; then
                ((pass_cnt+=1))
                log "pass_cnt=$pass_cnt"
		fail_cnt=0
	else
                echo "$bt_interface not exist" | tee -a $logfile
                ((fail_cnt+=1))
                log "$bt_interface not exist"
                log "fail_cnt=$fail_cnt"
        fi

        if [ "$fail_cnt" -ge 6  ]; then
                log "bluetooth pass_cnt = $pass_cnt fail_cnt $fail_cnt "
                exit
        fi

	sleep 2
done
