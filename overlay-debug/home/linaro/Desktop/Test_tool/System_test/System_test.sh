#!/bin/bash

version=2.9.20221129

select_test_item()
{
	echo "*******************************************"
	echo
	echo                "System Test tool v_$version"
	echo                "Model: $MODEL"
	echo
	echo "*******************************************"
	echo
	echo "1. Start shutdown test (need to manual power on/off)"
	echo "2. Start reboot test"
	echo "3. Start suspend test"
	echo "4. Stop test"
	echo "5. Check test count"
	read -p "Select test case: " test_item
	echo
}

info_view()
{
	echo "*******************************************"
	echo
	echo "          $1 stress test start"
	echo
	echo "*******************************************"
	echo "Reset test counter"
	sudo rm /etc/*_times.txt
}

pause(){
        read -n 1 -p "$*" INP
        if [ $INP != '' ] ; then
                echo -ne '\b \n'
        fi
}

log()
{
	timestamp="$(date +'%Y%m%d_%H%M')"
	logfile2="/dev/kmsg"
	echo -e $1 | sudo tee $logfile2
	logger -t system_test "[$timestamp]$1"
}

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`/etc
CONFIGPATH=`dirname $SCRIPT`/config


if [ ! -z "$1" ]; then
	PROJECT=$1
	MODEL=$PROJECT
	if [ $2 ];then
		test_item=$2
	else
		select_test_item
	fi
else
   echo "Need project name for test, Ex: PE100A, PE1000N"
   exit
fi

#MODEL=$PROJECT
#echo "$MODEL"
if [ -f "$CONFIGPATH/$PROJECT.cfg" ]; then
	CONFIGFILE=$CONFIGPATH/$PROJECT.cfg
	source $CONFIGFILE
	sudo rm /etc/temp_script_path
	sudo rm /etc/temp_config_path
	echo $SCRIPTPATH | sudo tee /etc/temp_script_path
	echo $CONFIGFILE | sudo tee /etc/temp_config_path
else
   echo "$PROJECT.cfg is not exist."
   exit
fi
#sudo bash /usr/bin/scan_io.sh

case $test_item in
	1)
		info_view Shutdown
		sudo cp $SCRIPTPATH/shutdown_test.sh /etc/init.d/
		sudo update-rc.d shutdown_test.sh defaults
		sudo update-rc.d shutdown_test.sh enable
		sudo bash -c "echo +20 > /sys/class/rtc/rtc0/wakealarm"
		sudo echo $SOC_TYPE > /etc/soc_type.txt
		SOC_TYPE_TEMP=`cat /etc/soc_type.txt`
		echo $SOC_TYPE_TEMP
		sync
		sleep 5
		#echo 1 | sudo tee /proc/sys/kernel/sysrq
		#echo o | sudo tee /proc/sysrq-trigger
		sudo systemctl poweroff
		;;
	2)
		info_view Reboot
		
		echo | sudo tee /etc/temp_check_io
		sudo cp $SCRIPTPATH/reboot_test.sh /etc/init.d/
		sudo update-rc.d reboot_test.sh defaults
		sudo update-rc.d reboot_test.sh enable
		sudo echo $SOC_TYPE > /etc/soc_type.txt
		SOC_TYPE_TEMP=`cat /etc/soc_type.txt`
		echo $SOC_TYPE_TEMP
		
		sync
		sleep 5
		if [ -f /etc/pci_device.txt ]; then
			sudo rm /etc/pci_device.txt
		fi
		
		#echo 1 | sudo tee /proc/sys/kernel/sysrq
		#echo b | sudo tee /proc/sysrq-trigger
		sudo systemctl reboot
		;;
	3)
		info_view Suspend
		times=0
		while true; do
			fail_file="/home/linaro/Desktop/Fail_suspend_resume.txt"
			if [ -f fail_file ]; then
				sudo rm -rf $fail_file
			fi
			log "trigger suspend"
			if [ "$SOC_TYPE" == "tegra" ]; then 
				# Set the rtc 1 to wakeup system
				sudo bash $SCRIPTPATH/suspend_test.sh 1
			else
				# Set the rtc 0 to wakeup system
				sudo bash $SCRIPTPATH/suspend_test.sh 0
			fi

			echo "suspend_times = "$times | sudo tee /etc/suspend_times.txt
			sleep 20
			((times+=1))
			if [ "$times" = 1 ]; then
				echo "sudo bash $SCRIPTPATH/scan_io.sh $CONFIGFILE"
				#sudo bash $SCRIPTPATH/scan_io.sh $CONFIGFILE
				result=`sudo bash $SCRIPTPATH/scan_io.sh $CONFIGFILE | grep Fail`
				if [ -n "$result" ]; then
					echo $result
					log $result
					echo $result >> /etc/suspend_times.txt
					sudo dmesg > /var/log/dmesg
					LOGFILE="${MODEL}_Suspend.tar"
					if [ "$SOC_TYPE" == "rockchip" ]; then 
						sudo tar -cvf /home/linaro/Desktop/$LOGFILE /var/log
					else
						sudo tar -cvf /home/asus/Desktop/$LOGFILE /var/log
					fi
					sleep 1
					touch $fail_file
					echo "scan_io.sh" >> $fail_file
					exit
				fi				
			fi
			
			log "resume to checkio and suspend_times = $times"
			result=`$SCRIPTPATH/check_io.sh $CONFIGFILE | grep Fail`
			if [ -n "$result" ]; then
				echo $result
				log $result
				echo $result >> /etc/suspend_times.txt
				sudo dmesg > /var/log/dmesg
				LOGFILE="${MODEL}_Suspend.tar"
				if [ "$SOC_TYPE" == "rockchip" ]; then 
					sudo tar -cvf /home/linaro/Desktop/$LOGFILE /var/log
				else
					sudo tar -cvf /home/asus/Desktop/$LOGFILE /var/log
				fi	
				sleep 1
				touch $fail_file
				echo "check_io.sh" >> $fail_file
				exit
			fi
		done
		;;
	4)
		echo "Stop test, device will reboot again after 5 second"
		sudo update-rc.d -f reboot_test.sh remove
		sudo update-rc.d -f shutdown_test.sh remove
		sudo bash -c "$SCRIPT $PROJECT 5"
		sleep 5
		LOGFILE="${MODEL}_Reboot_Shutdown.tar"
#		if [ "$SOC_TYPE" == "rockchip" ]; then 
#			sudo tar cvf /home/linaro/Desktop/$LOGFILE /var/log
#		else
#			sudo tar cvf /home/$USER/Desktop/$LOGFILE /var/log
#		fi
		sleep 1
		sudo systemctl reboot
		;;
	5)
		if [ -f /etc/shutdown_times.txt ]; then
			cat /etc/shutdown_times.txt
		fi
		if [ -f /etc/reboot_times.txt ]; then
			cat /etc/reboot_times.txt
		fi
		if [ -f /etc/suspend_times.txt ]; then
			cat /etc/suspend_times.txt
		fi
		;;
	*)
		echo "Unknown test case!"
		;;
esac

#pause 'Press any key to exit...'
