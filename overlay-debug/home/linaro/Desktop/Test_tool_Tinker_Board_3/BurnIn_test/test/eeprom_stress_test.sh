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

enable_eeprom_write()
{
	log "enable_eeprom_write"
	sudo su -c "echo "42" > /sys/class/gpio/unexport"
	sleep 0.2
	sudo su -c "echo "42" > /sys/class/gpio/export"
	sleep 0.2
	sudo su -c "echo "out" > /sys/class/gpio/gpio42/direction"
	sudo su -c "echo "0" > /sys/class/gpio/gpio42/value"
	sleep 0.1
}

disable_eeprom_write()
{
	log "disable_eeprom_write"
	sudo su -c "echo "42" > /sys/class/gpio/unexport"
	sleep 0.2
	sudo su -c "echo "42" > /sys/class/gpio/export"
	sleep 0.2
	sudo su -c "echo "out" > /sys/class/gpio/gpio42/direction"
	sudo su -c "echo "1" > /sys/class/gpio/gpio42/value"
	sleep 0.1
	sudo su -c "echo "42" > /sys/class/gpio/unexport"
	sleep 0.2
}

enable_eeprom_write

while [ 1 != 2 ]
do

	if [ -e /sys/class/i2c-dev/i2c-2/device/2-0050 ]; then

		sudo $i2cset -f -y 2 0x50 0xff 0x01
		read_value=`sudo $i2cget -f -y 2 0x50 0xff`

		echo "read_value=$read_value"

		int_1=0x01
		if [ $read_value == $int_1 ]
		then
			log "Read/Write value SAME"
			((pass_cnt+=1))
			log "pass_cnt=$pass_cnt"
		else
			log "Read/Write value Not SAME"
			((fail_cnt+=1))
			log "fail_cnt=$fail_cnt"
		fi
		sleep 2
		
		sudo $i2cset -f -y 2 0x50 0xff 0x02
		read_value=`sudo $i2cget -f -y 2 0x50 0xff`

		echo "read_value=$read_value"

		int_2=0x02
		if [ $read_value == $int_2 ]
		then
			log "Read/Write value SAME"
			((pass_cnt+=1))
			log "pass_cnt=$pass_cnt"
		else
			log "Read/Write value Not SAME"
			((fail_cnt+=1))
			log "fail_cnt=$fail_cnt"
		fi
		
	else
		log "EEPROM NOT FOUND"
		((fail_cnt+=1))
		log "fail_cnt=$fail_cnt"		
	fi
	sleep 2
	if [ "$fail_cnt" -ge 6  ]; then
		log "rtc pass_cnt = $pass_cnt fail_cnt $fail_cnt "
		disable_eeprom_write
		exit
	fi
done	
