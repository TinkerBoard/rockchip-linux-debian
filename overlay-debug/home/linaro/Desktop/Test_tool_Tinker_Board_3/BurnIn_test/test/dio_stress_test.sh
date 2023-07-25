#!/bin/bash
TAG=DIO
logfile=$1
GET_INPUT="i2cget -y 2 0x20 0x09"
high_err_cnt=0
low_err_cnt=0

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $TAG $@"  | tee -a $logfile
}

log "init the gpio direction"
i2cset -y 2 0x20 0 0x0f

i=0
while true
do
	log "=========== $i loop ============="
	
	log "Set GPIO[7:4] gpio values to high"
	i2cset -y 2 0x20 0x0a 0xf0
	sleep 1
	
	input_value=$(( $(eval $GET_INPUT) & 0x0f ))
	log "Read GPIO[3:0] input values: $input_value"
	if [[ $input_value -ne 0x0f ]]; then
		log "Error: GPIO[3:0] input values are not high"
		((high_err_cnt+=1))
	else
		high_err_cnt=0
	fi
	
	log "Set GPIO[7:4] gpio values to low"
	i2cset -y 2 0x20 0x0a 0
	sleep 1
	
	input_value=$(( $(eval $GET_INPUT) & 0x0f ))
	log "Read GPIO[3:0] input values: $input_value"
	if [ $input_value -ne 0 ]; then
		log "Error: GPIO[3:0] input values are not low"
		((low_err_cnt+=1))
	else
		low_err_cnt=0
	fi
	
	if [[ $high_err_cnt -ge 3 || $low_err_cnt -ge 3 ]]; then
		log "high_err_cnt=$high_err_cnt, low_err_cnt=$low_err_cnt, exit test"
		exit 1
	fi

	i=$(($i+1))
done
