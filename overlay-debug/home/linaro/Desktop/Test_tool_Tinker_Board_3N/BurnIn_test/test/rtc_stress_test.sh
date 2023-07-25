#!/bin/bash
TAG=RTC
logfile=$1
pass_cnt=0
fail_cnt=0

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do
	if [ -e /sys/class/rtc/rtc0/date ]; then
		date=`cat /sys/class/rtc/rtc0/date`
		if [ -n "$date" ]; then
			echo "RTC is working properly. Current date is: $date"
			log "RTC is working properly. Current date is: $date"
			((pass_cnt+=1))
			log "pass_cnt=$pass_cnt"

		else
			echo "RTC failed to return valid date."
			log "RTC failed to return valid date."
			((fail_cnt+=1))
			log "fail_cnt=$fail_cnt"
		fi
	else
		echo "RTC device not found."
		log  "RTC device not found."
		((fail_cnt+=1))
		log "fail_cnt=$fail_cnt"
	fi	
	if [ "$fail_cnt" -ge 6  ]; then
		log "rtc pass_cnt = $pass_cnt fail_cnt $fail_cnt "
		exit
	fi
	sleep 2
done
