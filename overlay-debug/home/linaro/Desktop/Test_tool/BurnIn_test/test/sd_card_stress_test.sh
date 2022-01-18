#!/bin/bash
times=0
rm_err_cnt=0
cp_err_cnt=0
now="$(date +'%Y%m%d_%H%M')"
logfile="$1/$now"_sd.txt

#Check SD card insert or not
sd_mount_point=$(cat /proc/mounts | grep mmcblk0 | awk '{print $2}')
sd_mount_point=$(echo $sd_mount_point | awk '{print $1}')

echo sd_mount_point = $sd_mount_point

if [ -z $sd_mount_point ]; then
	sd_blk=$(cat /proc/partitions | grep mmcblk0 | awk '{print $4}')
	if [ -z $sd_blk ]; then
		echo SD card not detect, exit test!! | tee $2 $logfile
		exit
	else
		echo SD card detect but not mounted | tee $2 $logfile
		echo File manager format not supported | tee $2 $logfile
		echo Please manually format SD to FAT32, exit test!! | tee $2 $logfile
		exit
	fi
fi

tmpfile=/$sd_mount_point/tmpfile

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
		echo "$(date +'%Y%m%d_%H%M') SD test pass $times times, cpu temp = $cpu_temp" | tee $2 $logfile
	fi 
	sleep 1

	if [[ $w_err_cnt -ge 5 || $r_err_cnt -ge 5 || $rm_err_cnt -ge 5 ]]; then
		echo "$(date +'%Y%m%d_%H%M') SD test continue fail over 5 times, w_err_cnt=$w_err_cnt, r_err_cnt=$r_err_cnt, rm_err_cnt=$rm_err_cnt"  | tee $2 $logfile
		exit 1
	fi
done


