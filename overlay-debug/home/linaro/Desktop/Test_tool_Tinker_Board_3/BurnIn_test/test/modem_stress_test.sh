#!/bin/bash
TAG=MODEM
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
	if [ -e "$atport" ]; then
		sudo systemctl stop asus-modem
		source /etc/modem/utils.sh
		read_value=`send_at_command AT`
		log "$read_value"
		if [[ "$read_value" =~ "OK" ]]
		then
			pass "AT OK"
		else
			fail "AT ERROR"
		fi
	else
		fail "AT PORT NOT FOUND"
	fi
	sleep 2

	if [ -e "$qmiport" ]; then
		read_value=`sudo qmicli -d "$qmiport" -p --dms-get-model`
		log "$read_value"
		if [[ "$read_value" =~ "Model:" ]]
		then
			pass "QMI OK"
		else
			fail "QMI ERROR"
		fi
	else
		fail "QMI PORT NOT FOUND"
	fi

	sleep 2
	if [ "$fail_cnt" -ge 6  ]; then
		log "modem pass_cnt = $pass_cnt fail_cnt $fail_cnt "
		exit
	fi
done
