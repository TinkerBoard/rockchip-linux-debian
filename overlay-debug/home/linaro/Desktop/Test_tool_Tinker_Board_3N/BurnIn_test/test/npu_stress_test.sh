#!/bin/bash
logfile=$1
pass_cnt=0

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}

while [ 1 != 2 ]
do
	result=$($SCRIPTPATH/rknn_common_test $SCRIPTPATH/mobilenet_v1.rknn $SCRIPTPATH/dog_224x224.jpg 10 | grep "0.984375 - 156")
	sleep 0.5
	if [[ -n "$result" ]]; then
		((pass_cnt+=1))
		log "pass_cnt=$pass_cnt"
	else
		log "The score didn't match, fail and exit !!!"
		exit
	fi
done
