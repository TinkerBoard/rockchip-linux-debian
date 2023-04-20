#!/bin/bash
TAG=IT5201FN
logfile=$1
pass_cnt=0
fail_cnt=0

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do
	sudo i2cset -f -y 3 0x67 0x10 0x47
	sudo i2cget -f -y 3 0x67 0x10
	sudo i2cset -f -y 3 0x67 0x1a 0x80
	sudo i2cget -f -y 3 0x67 0x1a
	sudo i2cget -f -y 3 0x67 0x16

	if [ "$?" == "0" ]; then
		log "cc chip i2c is working properly."
		((pass_cnt+=1))
		log "pass_cnt=$pass_cnt"
	else
		log "cc chip i2c failed to return valid value."
		((fail_cnt+=1))
		log "fail_cnt=$fail_cnt"
	fi

	if [ "$fail_cnt" -ge 6  ]; then
		log "IT5201FN i2c test pass_cnt = $pass_cnt fail_cnt $fail_cnt "
		exit
	fi
	sleep 5
done
