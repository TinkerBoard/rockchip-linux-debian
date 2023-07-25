#!/bin/bash
TAG=TPU
logfile=$1
logfile2=/home/root/coral-multitpus-stress-test-arm64/cts.txt
pass_cnt=0
err_cnt=0

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $TAG $@"  | tee -a $logfile
}

tpu_num=$( lspci -n | grep "1ac1:089a" | wc -l )
log "Detect $tpu_num TPU module"
log "Loop run TPU test: python3 coral_cts.py --tpu $tpu_num --inf 3000 --iteration 1"

cd /home/root/coral-multitpus-stress-test-arm64

while [ 1 != 2 ]
do
	rm $logfile2
	sleep 3
	python3 coral_cts.py --tpu $tpu_num --inf 3000 --iteration 1
	Result=`cat $logfile2 | grep Overall | awk '{print $3}'`
	if [ "$Result" == "Passed" ]
	then
		((pass_cnt+=1))
		err_cnt=0
	else
		((err_cnt+=1))
	fi
	head $logfile2 | tee -a $logfile
	log "TPU stress test, pass_cnt=$pass_cnt, err_cnt=$err_cnt"
	if [[ $err_cnt -ge 5 ]]; then
		exit
	fi
done

