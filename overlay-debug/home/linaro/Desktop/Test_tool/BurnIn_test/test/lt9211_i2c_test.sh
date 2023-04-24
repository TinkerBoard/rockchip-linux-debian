#!/bin/bash
TAG=RTC
logfile=$1
pass_cnt=0
fail_cnt=0
i2cget=/usr/sbin/i2cget
i2cset=/usr/sbin/i2cset

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do

	if [ -e /sys/class/i2c-dev/i2c-4/device/4-002d ]; then

		sudo $i2cset -f -y 4 0x2d 0xff 0x81
		read_value0=`sudo $i2cget -f -y 4 0x2d 0x00`
		read_value1=`sudo $i2cget -f -y 4 0x2d 0x01`
		read_value2=`sudo $i2cget -f -y 4 0x2d 0x02`

		echo "read_value0=$read_value0"
		echo "read_value1=$read_value1"
		echo "read_value2=$read_value2"

		int_0=0x18
		int_1=0x01
		int_2=0xe4
		
		if [ $read_value0 == $int_0 ] && [ $read_value1 == $int_1 ] && [ $read_value2 == $int_2 ]
		then
			log "Detect Success!"
			((pass_cnt+=1))
			log "pass_cnt=$pass_cnt"
		else
			log "Detect Fail"
			((fail_cnt+=1))
			log "fail_cnt=$fail_cnt"
		fi
		sleep 2

		if [ "$fail_cnt" -ge 6  ]; then
			log "lt9211 pass_cnt = $pass_cnt fail_cnt $fail_cnt "
			exit
		fi
	fi
done	
