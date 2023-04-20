#!/bin/bash
TAG=HUB
logfile=$1
u3_pass_cnt=0
u3_fail_cnt=0
u2_pass_cnt=0
u2_fail_cnt=0

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do
	lsusb|grep "05e3:0620"
	if [ "$?" == "0" ]; then
		log "Found Genesys Logic usb 3.2 hub."
		((u3_pass_cnt+=1))
		u3_fail_cnt=0
		log "u3_pass_cnt=$u3_pass_cnt"
	else
		log "Can not found Genesys Logic usb 3.2 hub."
		((u3_fail_cnt+=1))
		log "u3_fail_cnt=$u3_fail_cnt"
	fi

	lsusb|grep "05e3:0610"
	if [ "$?" == "0" ]; then
		log "Found Genesys Logic usb 2.0 hub."
		((u2_pass_cnt+=1))
		u2_fail_cnt=0
		log "u2_pass_cnt=$u2_pass_cnt"
	else
		log "Can not found Genesys Logic usb 2.0 hub."
		((u2_fail_cnt+=1))
		log "u2_fail_cnt=$u2_fail_cnt"
	fi

	if [ "$u3_fail_cnt" -ge 6  ]; then
		log "Genesys Logic usb 3.2 hub test pass_cnt = $u3_pass_cnt fail_cnt $u3_fail_cnt"
		log "Genesys Logic usb 2.0 hub test pass_cnt = $u2_pass_cnt fail_cnt $u2_fail_cnt"
		exit
	fi

	if [ "$u2_fail_cnt" -ge 6  ]; then
		log "Genesys Logic usb 3.2 hub test pass_cnt = $u3_pass_cnt fail_cnt $u3_fail_cnt"
		log "Genesys Logic usb 2.0 hub test pass_cnt = $u2_pass_cnt fail_cnt $u2_fail_cnt"
		exit
	fi

	sleep 5
done
