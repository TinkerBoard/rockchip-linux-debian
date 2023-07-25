#!/bin/bash
TAG=EMMC
mmcdev=$1
logfile=$2
cnt=0
pass_cnt=0
err_cnt=0
rm_err_cnt=0
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $TAG $@"  | tee -a $logfile
}

get_mount_point()
{
	ROOTFS_MMCBLK=$(lsblk | grep "part /" | grep -v "/[a-z]" | awk -F ' ' '{print $1}' | awk -F 'p' '{print $1}' | awk -F 'mmcblk' '{new_var="mmcblk"$2;print new_var}')
	log "rootfs_blk: $ROOTFS_MMCBLK"
	log "mmcdev: $mmcdev"
	if [ $ROOTFS_MMCBLK == $mmcdev ];then
		echo "$TAG boot up device"
		tmpfile="/tmpfile"
	else
		#Check MMC device exist or not
		mount_point=$(cat /proc/mounts | grep $mmcdev | awk '{print $2}')
		mount_point=$(echo $mount_point | awk '{print $1}')
		log" mount_point: $mount_point"

		if [ -z $mount_point ]; then
			mmc_blk=$(cat /proc/partitions | grep $mmcdev | awk '{print $4}')
			if [ -z $mmc_blk ]; then
				log "$TAG($mmcdev) not detect, exit test!!"
				exit
			else
				log "$TAG($mmcdev) detect but not mounted"
				log "File manager format not supported"
				log "Please manually format $TAG($mmcdev) to FAT32, exit test!!"
				exit
			fi
		fi
		
		if [ $mount_point == "/" ];then
			tmpfile="/tmpfile"
		else
			tmpfile=$mount_point/tmpfile
		fi 
	fi
}

get_mount_point
echo "tmpfile=$tmpfile"
log "tmpfile: $tmpfile"

while [ 1 != 2 ]
do
	((cnt+=1))
	cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
	cpu_temp=`awk 'BEGIN{printf "%.2f\n",('$cpu_temp'/1000)}'`

	# Remove testfile
	if [ -e ${tmpfile} ]; then
		rm ${tmpfile} > /dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			((rm_err_cnt+=1))
			log "Read/Write: fail , can't remove ${tmpfile}, cpu temp=$cpu_temp"
		else
			rm_err_cnt=0
		fi	
	fi
	sleep 1

	# Read/Write testfile
	echo $fifoStr > $tmpfile
	ReadStr=`cat $tmpfile`
	if [ $fifoStr == $ReadStr ]; then
		status="pass"
		((pass_cnt+=1))
	else
		status="fail"
		((err_cnt+=1))
	fi
	log "Read/Write: $status , pass_cnt=$pass_cnt, err_cnt=$err_cnt, cpu temp=$cpu_temp"
	
	if [ $err_cnt -ge 20 ]; then
		log "Fail: err_cnt=$err_cnt"
		exit
	fi
done
