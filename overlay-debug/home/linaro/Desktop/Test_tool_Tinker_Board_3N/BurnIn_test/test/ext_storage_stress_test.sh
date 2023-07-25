#!/bin/bash
TAG=$1
udev=$1
logfile=$2
cnt=0
pass_cnt=0
err_cnt=0
rm_err_cnt=0
fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"
auto_mount=1

log()
{
	echo "$(date +'%Y%m%d_%H.%M.%S') $TAG $@"  | tee -a $logfile
}

get_mount_point()
{
	if [ -e "/dev/"$udev"1" ]; then
		udev=$udev"1"
	fi

	#Check external storage mounut or not
	mount_point=$(cat /proc/mounts | grep $udev | awk '{print $2}')
	mount_point=$(echo $mount_point | awk '{print $1}')

	echo mount_point = $mount_point
	log "mount point = $mount_point"

	if [ -z $mount_point ]; then
		blk=$(cat /proc/partitions | grep $udev | awk '{print $4}')
		if [ -z $blk ]; then
			log "Storage not detect, exit test!!"
			exit
		else
			if [ "$auto_mount" == 0 ]; then
				log "Storage detect but not mounted"
				log "File manager format not supported"
				log "Please manually format external storage to FAT32, exit test!!"
				exit
			else
				sudo blkdiscard /dev/$udev
				sudo mkfs.vfat -I -F 32 /dev/$udev
				sudo mkdir /media/$udev
				sudo mount -o rw /dev/$udev /media/$udev
				mount_point=$(cat /proc/mounts | grep $udev | awk '{print $2}')
				mount_point=$(echo $mount_point | awk '{print $1}')
				if [ -z $mount_point ]; then
					log "mount storage fail, storage maybe corrupt"
					exit
				fi
			fi
		fi
	fi

	tmpfile=$mount_point/tmpfile
}

get_mount_point
echo "tmpfile=$tmpfile"
log "test file loc = $tmpfile"

while [ 1 != 2 ]
do
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
	if [[ $? -ne 0 ]]; then
		log "Read/Write: write fail , file is not esist"
	fi
	ReadStr=`cat $tmpfile`
	if [[ $? -ne 0 ]]; then
		log "Read/Write: read fail , file is not esist"
		exit
	fi
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
