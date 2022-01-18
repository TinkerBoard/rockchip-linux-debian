#!/bin/bash

tmpfile="$1/test/tmpfile"

times=0
w_err_cnt=0
r_err_cnt=0
rm_err_cnt=0

now="$(date +'%Y%m%d_%H%M')"
logfile="$1/$now"_emmc.txt

while [ 1 != 2 ]
do
	cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
	cpu_temp=`awk 'BEGIN{printf "%.2f\n",('$cpu_temp'/1000)}'`

	# Remove testfile
	if [ -e ${tmpfile} ]; then
		rm ${tmpfile} > /dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			((rm_err_cnt+=1))
		else
			rm_err_cnt=0
		fi	
	fi
	sleep 1

	# Write testfile
	dd if=/dev/zero of=${tmpfile} bs=1M count=5 conv=fdatasync > /dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		((w_err_cnt+=1))
	else
		w_err_cnt=0
	fi 
	sleep 1

	#Read testfile
	dd if=${tmpfile} of=/dev/null bs=1M count=5 > /dev/null 2>&1
 	if [[ $? -ne 0 ]]; then
		((r_err_cnt+=1))
	else
		r_err_cnt=0
		((times+=1))
		echo "$(date +'%Y%m%d_%H%M') eMMC test pass $times times, cpu temp = $cpu_temp" | tee $2 $logfile
	fi
	sleep 1

	if [[ $w_err_cnt -ge 5 || $r_err_cnt -ge 5 || $rm_err_cnt -ge 5 ]]; then
		echo "$(date +'%Y%m%d_%H%M') eMMC test continue fail over 5 times, w_err_cnt=$w_err_cnt, r_err_cnt=$r_err_cnt, rm_err_cnt=$rm_err_cnt"  | tee $2 $logfile
		exit 1
	fi
done
