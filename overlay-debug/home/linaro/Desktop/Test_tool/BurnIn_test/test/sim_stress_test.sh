#!/bin/bash
TAG=SIM
logfile=$1
pass_cnt=0
fail_cnt=0
qmiport=/dev/cdc-wdm0
atport=/dev/ttyUSB2

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

pass()
{
	log "$1"
	((pass_cnt+=1))
	log "pass_cnt=$pass_cnt"
}

fail()
{	log "$1"
	((fail_cnt+=1))
	log "fail_cnt=$fail_cnt"
}

sudo systemctl stop ModemManager
while [ 1 != 2 ]
do
	if [ -e "$qmiport" ]; then
		sudo qmicli -d "$qmiport" -p --uim-switch-slot=1
		read_value=`sudo qmicli -d "$qmiport" -p --uim-get-card-status`
		log "$read_value"
		if [[ "$read_value" =~ "Card state: 'present'" ]]
		then
			pass "SIM PRESENT"
		else
			fail "SIM NOT PRESENT"
		fi
	else
		fail "QMI PORT NOT FOUND"
	fi

	sleep 2
	if [ "$fail_cnt" -ge 6  ]; then
		log "sim pass_cnt = $pass_cnt fail_cnt $fail_cnt "
		exit
	fi
done
