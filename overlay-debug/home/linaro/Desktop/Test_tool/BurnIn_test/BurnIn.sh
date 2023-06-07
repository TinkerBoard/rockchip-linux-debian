#!/bin/bash

version=4.11.20221129

COLOR_REST='\e[0m'
COLOR_GREEN='\e[0;32m';
COLOR_RED='\e[0;31m';

log()
{
	logfile=$LOG_PATH/BurnIn.txt
	logfile2="/dev/kmsg"
	echo -e $1 | sudo tee -a $logfile | sudo tee $logfile2
	logger -t BurnIn "$1"
}

declare -A mmc_type_group
for i in `ls /sys/bus/mmc/devices/`
do
	mmc_type_group[$i]=`cat /sys/bus/mmc/devices/$i/type`
done

return_emmc_dev() {
	for i in "${!mmc_type_group[@]}"
	do
		if [[ "${mmc_type_group[$i]}" == "MMC" ]];then
			echo | ls /sys/bus/mmc/devices/$i/block/
		fi
	done
}

return_sd_dev() {
	for i in "${!mmc_type_group[@]}"
	do
		if [[ "${mmc_type_group[$i]}" == "SD" ]];then
			echo | ls /sys/bus/mmc/devices/$i/block/
		fi
	done
}

declare -A disk_type

return_ext_disk_dev() {
	for i in `ls /sys/block/ | grep sd`
	do
		if [ `realpath /sys/block/$i | grep fcc00000` ]; then
			disk_type[$i]=USB-C
		elif [ `realpath /sys/block/$i | grep fd800000` ]; then
                        disk_type[$i]=USB-NOHUB
		elif [ `realpath /sys/block/$i | grep fd000000` ]; then
			disk_type[$i]=USB-A
			if [ `cat /sys/block/$i/removable` == 0 ];then
				disk_type[$i]=MSATA
			fi
		else
			disk_type[$i]=USB
		fi
	done

	for i in `ls /sys/block/ | grep nvme`
	do
		if [ `realpath /sys/block/$i | grep usb` ]; then
			disk_type[$i]=USB
		else
			disk_type[$i]=PCIE
		fi
	done
}

emmcdev=`return_emmc_dev`
sddev=`return_sd_dev`
return_ext_disk_dev

select_test_item()
{
	echo "============================================"
	echo
	echo "       $PROJECT Burn In Test v_$version"
	echo "       Check LTE: $DO_LTE_CHECK Chheck GPS: $DO_GPS_CHECK"
	echo "       Thermal logging: $DO_THERMAL_LOGGING"
	echo "============================================"
	initial_setting
	echo
	echo " 0. (Default) All"
	echo " 1. CPU stress test: $DO_CPU_TEST"
	echo " 2. GPU stress test: $DO_GPU_TEST"
	echo " 3. DDR stress test: $DO_DDR_TEST"
	echo " 4. eMMC stress test: $DO_eMMC_TEST"
	echo " 5. SD card stress test: $DO_SD_TEST"
	echo " 6. External Storage stress test: $DO_EXTERNALSTORAGE_TEST"
	echo " 7. Ethernet stress test: $DO_ETHERNET_TEST"
	echo " 8. Wi-Fi stress test: $DO_WIFI_TEST"
	if [ $SOC_TYPE == "rockchip" ]; then
		echo " 9. NPU stres test: $DO_NPU_TEST"
		echo "10. COM1/COM2/COM3 RS232 stress test: $DO_UART_TEST"
		echo "11. RTC stress test: $DO_RTC_TEST"
		echo "12. EEPROM stress test: $DO_EEPROM_TEST"
		echo "13. SIM stress test: $DO_SIM_TEST"
		echo "14. Bluetooth stress test: $DO_BT_TEST"
		echo "15. LT9211 stress test: $DO_LT9211_TEST"
		echo "16. LED enable test: $DO_LED_TEST"
		echo "17. USB HUB check test: $DO_USBHUB_CHECK"
		echo "18. USB CC logic stress test: $DO_USBCC_TEST"
		echo "19. Audio loopback stress test:: $DO_AUDIO_TEST"
		echo "20. Audio amplifier stress test:: $DO_AUDIOAMP_TEST"
	else
                echo " 9. UART loopback stress test: $DO_UART_TEST"
                echo "10. UART1/UART2 RS232 stress test: $DO_UART_to_UART_TEST"
                echo "11. TPU stres test: $DO_TPU_TEST"
                echo "12. CAN bus stress test: $DO_CAN_TEST"
                echo "13. Audio stress test: $DO_AUDIO_TEST"
                echo "14. MCU DIO stress test: $DO_MCU_DIO_TEST"
                echo "15. MCU COM RS232 stress test: $DO_MCU_UART_TEST"
                echo "16. GPS stress test: $DO_GPS_TEST"
                echo "17. AEM Ethernet test : $DO_AEM_ETHERNET_TEST"
	fi
	read -p "Select test case: " test_item
}

select_gps_module()
{
	if [ $SOC_TYPE == "tegra" ]; then
		gps_module=$GPS_MODULE
	else
	echo
		echo "0. U-blox GPS"
		echo "1. Locosys GPS"
		echo "2. Quectel GPS"
	echo
		read -p "Select GPS module: " gps_module_select
		gps_module=$gps_module_select
	fi
	echo "GPS module is $gps_module"
}

info_view()
{
	echo "============================================"
	echo
	echo "       $1 stress test start"
	echo
	echo "============================================"
}

high_performance()
{
	echo
	echo "1. disable thermal policy"
	echo "2. keep thermal policy "
	read -p  "Select thermal policy: " thermal
	echo
	sudo bash $SCRIPTPATH/test/high_performance.sh $thermal > /dev/null 2>&1
}

cpu_freq_stress_test()
{
	logfile=$LOG_PATH/cpu.txt
	time=2592000 # 30 days = 60 * 60 * 24 * 30
	killall cpu_freq_stress_test.sh > /dev/null 2>&1
	killall stressapptest > /dev/null 2>&1
	$SCRIPTPATH/test/cpu_freq_stress_test.sh $SCRIPTPATH $time $logfile > /dev/null 2>&1 &
}

gpu_test()
{
	logfile=$LOG_PATH/gpu.txt
	if [ $SOC_TYPE == "imx8" ]; then
		killall glmark2-es2-wayland > /dev/null 2>&1
	elif [ $SOC_TYPE == "tegra" ]; then
		killall glmark2 > /dev/null 2>&1
	fi 
    	bash $SCRIPTPATH/test/gpu_stress.sh $SOC_TYPE $GPU_TEST_NUM
}

ddr_test()
{
	logfile=$LOG_PATH/ddr.txt
	killall memtester > /dev/null 2>&1
	sudo $SCRIPTPATH/test/memtester $1 > $logfile &
}

emmc_stress_test()
{
	logfile=$LOG_PATH/emmc.txt
	killall emmc_stress_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/emmc_stress_test.sh $emmcdev $logfile
}

sd_card_stress_test()
{
	logfile=$LOG_PATH/sd.txt
	killall sd_card_stress_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/sd_card_stress_test.sh $sddev $logfile
}

ext_storage_stress_test()
{
	killall ext_storage_stress_test.sh > /dev/null 2>&1
	if [[ ${#disk_type[@]} -eq 0 ]];then
		ext_disk_exist=0
	else
		ext_disk_exist=1
		for i in "${!disk_type[@]}"
		do
			logfile=$LOG_PATH/${i}.txt
			if [ $1 == "ui" ]; then
				#xterm -fg lightgray -bg black -e "$SCRIPTPATH/test/ext_storage_stress_test.sh $i $logfile" &
				/usr/bin/xfce4-terminal --command "$SCRIPTPATH/test/ext_storage_stress_test.sh $i $logfile" --hold &
			else
				$SCRIPTPATH/test/ext_storage_stress_test.sh $i $logfile > /dev/null 2>&1 &
			fi
		done
	fi
}

network_stress_test()
{
	logfile=$LOG_PATH/network.txt
	killall network_stress_test.sh > /dev/null 2>&1
	killall check_network.sh > /dev/null 2>&1
	killall iperf3 > /dev/null 2>&1
	$SCRIPTPATH/test/$SOC_TYPE/network_stress_test.sh $logfile &
	if [ "$SOC_TYPE" == "rockchip" ]; then
		sleep 5
		$SCRIPTPATH/test/$SOC_TYPE/check_network.sh $logfile &
	else
                sleep 10
                $SCRIPTPATH/test/check_network.sh $logfile &
	fi
}

aem_network_stress_test()
{
	logfile=$LOG_PATH/aem_network.txt
	killall aem_network_stress_test.sh > /dev/null 2>&1
	killall iperf3 > /dev/null 2>&1
	$SCRIPTPATH/test/$SOC_TYPE/aem_network_stress_test.sh $logfile &
	sleep 10
	$SCRIPTPATH/test/check_aem_network.sh $logfile &
}

wifi_stress_test()
{
	logfile=$LOG_PATH/wifi.txt
	killall wifi_stress_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/wifi_stress_test.sh $SCRIPTPATH $logfile $SOC_TYPE
}

bluetooth_stress_test()
{
        logfile=$LOG_PATH/bluetooth.txt
        killall bluetooth_stress_test.sh > /dev/null 2>&1
        $SCRIPTPATH/test/bluetooth_stress_test.sh $SCRIPTPATH $logfile $SOC_TYPE
}

led_test()
{
        killall led_test.sh > /dev/null 2>&1
        $SCRIPTPATH/test/rockchip/led_test.sh 1 1
}

led_disable()
{
        killall led_test.sh > /dev/null 2>&1
        $SCRIPTPATH/test/rockchip/led_test.sh 0 0
}

usbcc_stress_test()
{
        logfile=$LOG_PATH/usbcc.txt
        killall cc_i2c_stress_test.sh > /dev/null 2>&1
        $SCRIPTPATH/test/cc_i2c_stress_test.sh $logfile
}

uart_stress_test()
{
	logfile1=$LOG_PATH/uart1.txt
	logfile2=$LOG_PATH/uart2.txt
	logfile3=$LOG_PATH/uart3.txt
	killall uart1_stress_test.sh > /dev/null 2>&1
	killall uart2_stress_test.sh > /dev/null 2>&1
	killall uart3_stress_test.sh > /dev/null 2>&1
	killall linux-serial-test > /dev/null 2>&1
	sleep 1
	if [ $1 == "ui" ]; then
		#xterm -fg lightgray -bg black -e "$SCRIPTPATH/test/uart2_stress_test.sh $logfile2" &
		/usr/bin/xfce4-terminal --command "$SCRIPTPATH/test/uart3_stress_test.sh $COM_3 $logfile3" --hold &
		sleep 1
		/usr/bin/xfce4-terminal --command "$SCRIPTPATH/test/uart2_stress_test.sh $COM_2 $logfile2" --hold &
		sleep 1
		$SCRIPTPATH/test/uart1_stress_test.sh $COM_1 $logfile1
	else
		$SCRIPTPATH/test/uart1_stress_test.sh $COM_1 $logfile1 > /dev/null 2>&1 &
		$SCRIPTPATH/test/uart2_stress_test.sh $COM_2 $logfile2 > /dev/null 2>&1 &
		$SCRIPTPATH/test/uart3_stress_test.sh $COM_3 $logfile3 > /dev/null 2>&1 &
	fi
}

uart_to_uart_stress_test()
{
	logfile=$LOG_PATH/uart.txt
	killall serial-test_loop.sh > /dev/null 2>&1
	killall serial-test > /dev/null 2>&1
	ex_gpio -c 1 $COM_TEST_TYPE > /dev/null 2>&1
	ex_gpio -c 2 $COM_TEST_TYPE > /dev/null 2>&1
	$SCRIPTPATH/test/serial-test_loop.sh $COM_1 $COM_2 $SCRIPTPATH $logfile $SOC_TYPE
}

can_stress_test()
{
	logfile=$LOG_PATH/can.txt
	killall can_loopback.sh > /dev/null 2>&1
	$SCRIPTPATH/test/can_loopback.sh $SCRIPTPATH $logfile
}

audio_stress_test()
{
	logfile=$LOG_PATH/audio.txt
	killall audio_loopback_test.sh > /dev/null 2>&1
	killall audio_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/audio/audio_loopback_test.sh $logfile
}

audioamp_stress_test()
{
        logfile=$LOG_PATH/audio_amplifier_test.txt
        killall audio_amplifier_test.sh > /dev/null 2>&1
        $SCRIPTPATH/test/audio/audio_amplifier_test.sh $logfile
}

mcu_dio_stress_test()
{
	logfile=$LOG_PATH/mcu_dio.txt
	killall mcu_dio_stress_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/$SOC_TYPE/mcu_dio_stress_test.sh $SCRIPTPATH $logfile
}

mcu_uart_stress_test()
{
	logfile=$LOG_PATH/mcu_uart.txt
	killall mcu_uart_stress_test.sh > /dev/null 2>&1
	ex_gpio -c 3 $COM_TEST_TYPE > /dev/null 2>&1
	ex_gpio -c 4 $COM_TEST_TYPE > /dev/null 2>&1
	$SCRIPTPATH/test/mcu_uart_stress_test.sh $SCRIPTPATH $logfile
}

tpu_stress_test()
{
	logfile=$LOG_PATH/tpu.txt
	killall tpu_stress_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/tpu_stress_test.sh $logfile
}

npu_stress_test()
{
	logfile=$LOG_PATH/npu.txt
	killall npu_stress_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/npu_stress_test.sh $logfile
}

rtc_stress_test()
{
	logfile=$LOG_PATH/rtc.txt
	killall rtc_stress_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/rtc_stress_test.sh $logfile
}

eeprom_stress_test()
{
	logfile=$LOG_PATH/eeprom.txt
	killall eeprom_stress_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/eeprom_stress_test.sh $logfile
}
modem_stress_test()
{
	logfile=$LOG_PATH/modem.txt
	killall modem_stress_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/modem_stress_test.sh $logfile
}

sim_stress_test()
{
        logfile=$LOG_PATH/sim.txt
        killall sim_stress_test.sh > /dev/null 2>&1
        $SCRIPTPATH/test/sim_stress_test.sh $logfile
}

gps_stress_test(){
    #logfile=$LOG_PATH/gps.txt
    killall gpstest > /dev/null 2>&1
    sudo gnome-terminal --geometry 80x45+1200+500 --title="GPS" -e "$SCRIPTPATH/../GPS_test/gpstest /dev/ttyUSB1 quectel info" > /dev/null 2>&1 &
}

lt9211_stress_test()
{
	logfile=$LOG_PATH/lt9211.txt
	killall lt9211_i2c_test.sh > /dev/null 2>&1
	$SCRIPTPATH/test/lt9211_i2c_test.sh $logfile
}

thermal_logging()
{
	logfile=$LOG_PATH/thermal.csv
	if [ "$SOC_TYPE" == "tegra" ]; then
		killall thermal_logging.sh > /dev/null 2>&1
		$SCRIPTPATH/test/thermal_logging.sh $SOC_TYPE $logfile
	fi
}

get_device_info()
{
	cpu_usage=$(top -b -n2 -d0.1 | grep "Cpu(s)" | awk '{print $2+$4+$6+$14 "%"}' | tail -n1)

	cpu_temp=$(cat $CMD_CPU_TEMP)
	cpu_temp=`awk 'BEGIN{printf "%.2f\n",('$cpu_temp'/1000)}'`

	cpu_freq=`cat $CMD_CPU_FREQ`
	cpu_freq=`awk 'BEGIN{printf "%.2f\n",('$cpu_freq'/1000000)}'`

	if [ ! -z "$CMD_DDR_FREQ" ]; then
		if [ "$SOC_TYPE" == "imx8" ]; then
			ddr_freq=`sudo cat $CMD_DDR_FREQ | grep dram_core_clk | awk '{print $4}'`
			ddr_freq=`expr $ddr_freq \* 2 / 1000000`
		elif [ "$SOC_TYPE" = "tegra" ] || [ "$SOC_TYPE" = "rockchip" ]; then
			ddr_freq=`sudo cat $CMD_DDR_FREQ`
			ddr_freq=`expr $ddr_freq / 1000000`
		fi
	fi

	gpu_freq=`sudo cat  $CMD_GPU_FREQ`
	gpu_freq=`expr $gpu_freq / 1000000`

	if [ ! -z "$CMD_GPU_TEMP" ]; then
		gpu_temp=`cat  $CMD_GPU_TEMP`
		gpu_temp=`awk 'BEGIN{printf "%.2f\n",('$gpu_temp'/1000)}'`
	fi

	gpu_usage=`cat $CMD_GPU_USAGE`
	if [ "$SOC_TYPE" == "rockchip" ]; then
		gpu_usage=`echo $gpu_usage | awk '{print $1 "%"}'`
	elif [ "$SOC_TYPE" == "tegra" ]; then
		gpu_usage=`awk 'BEGIN{printf "%.2f\n",('$gpu_usage'/10)}'`
	fi

	#gpu_usage=`expr $gpu_usage / 10`
}

check_status()
{
	Flag=$( ps aux | grep "$2" | grep -v "grep")
	if [ "$Flag" == ""  ]
	then
		log "$1 stress test : ${COLOR_RED}stop${COLOR_REST} "
	else
		log "$1 stress test : ${COLOR_GREEN}running${COLOR_REST} "
	fi
}

check_ext_storage_status()
{
	if [ "$ext_disk_exist" == 0 ];then
		log "Ext Storage stress test: ${COLOR_RED}stop${COLOR_REST} "
	else
		for i in "${!disk_type[@]}"
		do
			if [ -f $LOG_PATH/${i}.txt ]; then
				Flag=`tail -n1 $LOG_PATH/${i}.txt | awk '{print $4}'`
				if [ "$Flag" == "pass"  ]
				then
					log "${disk_type[$i]}-${i} stress test : ${COLOR_GREEN}running${COLOR_REST} "
				else
					log "${disk_type[$i]}-${i} stress test : ${COLOR_RED}stop${COLOR_REST} "
				fi
			else
				log "${disk_type[$i]}-${i} stress test : ${COLOR_RED}stop${COLOR_REST} "
			fi
		done
	fi
}

check_wifi()
{
	if [ -f $LOG_PATH/wifi.txt ]; then
		Flag=`tail -n1 $LOG_PATH/wifi.txt | awk '{print $4}'`
		if [ "$Flag" == "fail"  ]
		then
			log "WiFi stress test : ${COLOR_RED}stop${COLOR_REST} "
		else
			log "WiFi stress test : ${COLOR_GREEN}running${COLOR_REST} "
		fi
	else
		log "WiFi stress test : ${COLOR_RED}stop${COLOR_REST} "
	fi
}

check_SSD()
{
    echo "check SSD"
}

check_lte()
{
	Flag=$( lsusb | grep "2c7c")
	if [ "$Flag" == ""  ]
	then
		log "LTE stress check : ${COLOR_RED}stop${COLOR_REST} "
	else
		log "LTE stress check : ${COLOR_GREEN}running${COLOR_REST} "
	fi
}

check_gps()
{
	$SCRIPTPATH/../GPS_test/gps_test.sh 0 $gps_module > /dev/null 2>&1 &
	sleep 10
	Flag=`tail -n1 /var/log/gps/GPSTest-CheckModule.log`
	if [ "$Flag" == "PASS"  ]
	then
		log "GPS stress check : ${COLOR_GREEN}running${COLOR_REST} "
	else
		log "GPS stress check : ${COLOR_RED}stop${COLOR_REST} "
		log "GPS stress check fail: $Flag"
		killall gps_test.sh > /dev/null 2>&1
		rm /var/lock/LCK..ttyUSB2
	fi
}

#check_gps()
#{
#	Flag=$( sudo bash $SCRIPTPATH/../GPS_test/gps_test.sh 0 $gps_module | grep FAIL)
#	if [ "$Flag" == "FAIL"  ]
#	then
#		log "GPS stress check : ${COLOR_RED}stop${COLOR_REST} "
#	else
#		log "GPS stress check : ${COLOR_GREEN}running${COLOR_REST} "
#	fi
#}

check_wifi_setting()
{
	sudo nmcli c delete ${AP_NAME}
	results=` sudo nmcli d wifi connect ${AP_NAME} password ${AP_PW} | awk '{print $3 " "}'`
	if [ $results == "successfully" ]; then
		echo "       check_wifi_setting: $results"
	else 
		echo "       check_wifi_setting: fail"
		exit
	fi
}

check_usbhub()
{
        logfile=$LOG_PATH/usbhub.txt
        killall check_usb_hub.sh > /dev/null 2>&1
        $SCRIPTPATH/test/check_usb_hub.sh $logfile
}

initial_setting()
{
	if [[ "$DO_WIFI_TEST" == "Y" ]]; then
		if [ "$SOC_TYPE" == "rockchip" ]; then
			checkwlan0=` ifconfig | grep wlp1s0`
		else
			checkwlan0=` ifconfig | grep wlan0`
		fi
		if [ "$SOC_TYPE" == "tegra" ]; then
			if [[ $checkwlan0 ]]; then
   				check_wifi_setting
			fi
		fi
	fi
	if [[ "$DO_SSD_CHECK" == "Y" ]]; then
   		check_SSD
	fi
	
	sudo killall -9 ModemManager
	sudo systemctl stop ModemManager
	
	if [[ $SOC_TYPE == "tegra" ]]; then
		# force power mode 
		sudo $CMD_SOC_SPECIAL_1
		# show clock setting
		sudo $CMD_SOC_SPECIAL_2
		# disable session idle
		sudo $CMD_SOC_SPECIAL_3
		# launch jtop
		if [[ $CMD_SOC_SPECIAL_4 ]]; then
			sudo gnome-terminal -e $CMD_SOC_SPECIAL_4
		fi
	fi
}

check_all_status()
{
	if [ "$DO_CPU_TEST" == "Y" ]; then
		check_status CPU $CPU
	fi
	if [ "$DO_GPU_TEST" == "Y" ]; then
		check_status GPU $GPU
	fi
	if [ "$DO_DDR_TEST" == "Y" ]; then
		check_status DDR $DDR
	fi
	if [ "$DO_eMMC_TEST" == "Y" ]; then
		check_status EMMC $EMMC
	fi
	if [ "$DO_SD_TEST" == "Y" ];then
		check_status SD $SD
	fi
	if [ "$DO_EXTERNALSTORAGE_TEST" == "Y" ]; then
		check_ext_storage_status
	fi

	if [ "$DO_ETHERNET_TEST" == "Y" ]; then
		check_status Ethernet $Ethernet
	fi

	if [ "$DO_WIFI_TEST" == "Y" ]; then
		check_status WIFI $WIFI
	fi

        if [ "$DO_BT_TEST" == "Y" ]; then
                check_status BLUETOOTH $BLUETOOTH
        fi

	if [ "$DO_UART_TEST" == "Y" ]; then
		if [ $SOC_TYPE == "rockchip" ]; then
			check_status COM1 $UART1
			check_status COM2 $UART2
			check_status COM3 $UART3
		else
                        check_status UART1 $UART1
                        check_status UART2 $UART2
                        check_status UART3 $UART3
		fi
	fi
	if [ "$DO_UART_to_UART_TEST" == "Y" ]; then
		check_status UARTtoUART $UART_1TO2
	fi
	if [ "$DO_CAN_TEST" == "Y" ]; then
		check_status CAN $CAN
	fi
	if [ "$DO_AUDIO_TEST" == "Y" ]; then
		check_status AUDIO $AUDIO
	fi
        if [ "$DO_AUDIOAMP_TEST" == "Y" ]; then
                check_status AUDIOAMP $AUDIOAMP
        fi
	if [ "$DO_MCU_DIO_TEST" == "Y" ]; then
		check_status MCU_DIO $MCU_DIO
	fi
	if [ "$DO_MCU_UART_TEST" == "Y" ]; then
		check_status MCU_UART $MCU_UART
	fi
	if [ "$DO_TPU_TEST" == "Y" ]; then
		check_status TPU $TPU
	fi
	if [ "$DO_LTE_CHECK" == "Y" ]; then
		check_lte
	fi
	if [ "$DO_GPS_CHECK" == "Y" ]; then
		check_gps
	fi
 	if [ "$DO_GPS_TEST" == "Y" ]; then
		check_status GPS $GPS
	fi
	if [ "$DO_AEM_ETHERNET_TEST" == "Y" ]; then
		check_status AEM_Ethernet $AEM_Ethernet
	fi
	if [ "$DO_NPU_TEST" == "Y" ]; then
		check_status NPU $NPU
	fi

	if [ "$DO_RTC_TEST" == "Y" ]; then
		check_status RTC $RTC
	fi

	if [ "$DO_EEPROM_TEST" == "Y" ]; then
		check_status EEPROM $EEPROM
	fi

	if [ "$DO_MODEM_TEST" == "Y" ]; then
		check_status MODEM $MODEM
	fi
        if [ "$DO_SIM_TEST" == "Y" ]; then
                check_status SIM $SIM
        fi
	if [ "$DO_LT9211_TEST" == "Y" ]; then
		check_status LT9211 $LT9211
	fi
        if [ "$DO_USBHUB_CHECK" == "Y" ]; then
                check_status USBHUB $USBHUB
        fi
        if [ "$DO_USBCC_TEST" == "Y" ]; then
                check_status USBCC $USBCC
        fi

#	check_status UART1 $UART1
#	check_status UART2 $UART2
}

kill_test(){
	killall cpu_freq_stress_test.sh > /dev/null 2>&1
	killall stressapptest > /dev/null 2>&1
	if [ $SOC_TYPE == "imx8" ]; then
		killall glmark2-es2-wayland > /dev/null 2>&1
	elif [ $SOC_TYPE == "tegra" ]; then
		killall glmark2 > /dev/null 2>&1
	elif [ $SOC_TYPE == "rockchip" ]; then
		killall glmark2-es2 > /dev/null 2>&1
	fi 
	killall memtester > /dev/null 2>&1
	killall emmc_stress_test.sh > /dev/null 2>&1
	killall sd_card_stress_test.sh > /dev/null 2>&1
	killall ext_storage_stress_test.sh > /dev/null 2>&1
	killall network_stress_test.sh > /dev/null 2>&1
	killall aem_network_stress_test.sh > /dev/null 2>&1
	killall iperf3 > /dev/null 2>&1
	killall wifi_stress_test.sh > /dev/null 2>&1
	killall bluetooth_stress_test.sh > /dev/null 2>&1
	killall uart1_stress_test.sh > /dev/null 2>&1
	killall uart2_stress_test.sh > /dev/null 2>&1
	killall uart3_stress_test.sh > /dev/null 2>&1
	killall linux-serial-test > /dev/null 2>&1
	killall tpu_stress_test.sh > /dev/null 2>&1
	killall serial-test_loop.sh > /dev/null 2>&1
	killall serial-test > /dev/null 2>&1
	killall mcu_dio_stress_test.sh > /dev/null 2>&1
	killall mcu_uart_stress_test.sh > /dev/null 2>&1
	killall AudioTest.sh > /dev/null 2>&1
	killall can_loopback.sh > /dev/null 2>&1
	killall gpstest > /dev/null 2>&1
	killall thermal_logging.sh > /dev/null 2>&1
	killall check_network.sh > /dev/null 2>&1
	killall check_aem_network.sh > /dev/null 2>&1
	killall npu_stress_test.sh > /dev/null 2>&1
	killall lt9211_i2c_test.sh > /dev/null 2>&1
	killall eeprom_stress_test.sh > /dev/null 2>&1
	killall rtc_stress_test.sh > /dev/null 2>&1
	killall led_test.sh > /dev/null 2>&1
	led_disable
	killall check_usb_hub.sh > /dev/null 2>&1
	killall cc_i2c_stress_test.sh > /dev/null 2>&1
        killall modem_stress_test.sh > /dev/null 2>&1
	killall sim_stress_test.sh > /dev/null 2>&1
        killall audio_loopback_test.sh > /dev/null 2>&1
        killall audio_test.sh > /dev/null 2>&1
	killall audio_amplifier_test.sh > /dev/null 2>&1

}

check_system_status=false
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
if [ ! -z "$1" ]; then
   PROJECT=$1
else
   echo "Need project name for test, Ex: PE100A, PE1000N"
   exit
fi
if [ -f "$SCRIPTPATH/config/$PROJECT.cfg" ]; then
   source $SCRIPTPATH/config/$PROJECT.cfg
else
   echo "$PROJECT.cfg is not exist."
   exit
fi

#if [ ! -z "$2" ]; then
#	sn=$2
#	top_path="/home/asus/stress_test"
#	log_path=/home/asus/stress_test/logs
#	if [ ! -e $log_path ]; then
#		mkdir -p $log_path
#	fi
#	sudo sh -c "chmod 755 -R $top_path"
#	sudo rm $top_path/logs/*.*
#	logfile="$top_path/logs/${sn}_$now"_burn_in_info.txt
#else
#	sn="test"
#fi

if [ ! -z "$2" ]; then
	test_time=$2
else
	# 10 days:10x24x60x60
	test_time=864000
fi

oemid=$(cat /proc/odmid)
projectid=$(cat /proc/projectid)
 
if [ "$oemid" == "15" ] ; then
	DO_ETHERNET_TEST=N
	echo "Only one Ethernet port"
elif [ "$oemid" == "18" ] && [ "$projectid" == "12" ]; then
	DO_ETHERNET_TEST=N
	echo "Only one Ethernet port"
fi

if [ ! -z "$3" ]; then
	test_item=$3
else
	select_test_item
fi

if [ "$DO_GPS_CHECK" == "Y" ]; then
   select_gps_module
fi

if [ ! -z "$4" ]; then
	thermal=$4
else
high_performance
fi

sn=$5
sudo chmod 755 $SCRIPTPATH/test/*.sh

sudo rm -r /var/log/burnin_test/*
sudo rm -rf /home/linaro/Desktop/burnin_test
start_time="$(date +'%Y%m%d_%H%M')"
if [ ! -z "$sn" ]; then
   LOG_NAME=$sn"_"$start_time
else
   LOG_NAME=$PROJECT"_"$start_time
fi
LOG_PATH=/var/log/burnin_test/$LOG_NAME
mkdir -p $LOG_PATH
sudo ln -s /var/log/burnin_test /home/linaro/Desktop/burnin_test
start_time="$(date +'%Y/%m/%d/%H:%M:%S')"
start_sec=$(date +%s)
log "SN = $sn"


CPU="/test/stressapptest -s 864000 --pause_delay 3600 --pause_duration 1 -W --stop_on_errors"
GPU="glmark2 --benchmark refract --run-forever --off-screen"
DDR="/test/memtester"
EMMC="/test/emmc_stress_test.sh"
SD="/test/sd_card_stress_test.sh"
Ethernet="/test/$SOC_TYPE/network_stress_test.sh"
AEM_Ethernet="/test/$SOC_TYPE/aem_network_stress_test.sh"
UART_1TO2="/test/serial-test_loop.sh"
UART1="/test/uart1_stress_test.sh"
UART2="/test/uart2_stress_test.sh"
UART3="/test/uart3_stress_test.sh"
CAN="/test/can_loopback.sh"
MCU_DIO="mcu_dio_stress_test.sh"
MCU_UART="mcu_uart_stress_test.sh"
TPU="/test/tpu_stress_test.sh"
GPS="../GPS_test/gpstest"
NPU="npu_stress_test.sh"
RTC="/test/rtc_stress_test.sh"
EEPROM="/test/eeprom_stress_test.sh"
MODEM="/test/modem_stress_test.sh"
SIM="/test/sim_stress_test.sh"
BLUETOOTH="/test/bluetooth_stress_test.sh"
WIFI="/test/wifi_stress_test.sh"
LT9211="/test/lt9211_i2c_test.sh"
USBCC="/test/cc_i2c_stress_test.sh"
USBHUB="/test/check_usb_hub.sh"
AUDIO="/test/audio/audio_loopback_test.sh"
AUDIOAMP="/test/audio/audio_amplifier_test.sh"

if [ "$DO_THERMAL_LOGGING" == "Y" ]; then
	thermal_logging > /dev/null 2>&1 &
fi

case $test_item in
	1)
		check_system_status=true
		info_view CPU
		cpu_freq_stress_test
		;;
	2)
		check_system_status=true
		info_view GPU
		gpu_test
		;;
	3)
		check_system_status=true
		info_view DDR
		ddr_test 64MB
		;;
	4)
		info_view eMMC_RW
		emmc_stress_test
		;;
	5)
		info_view SD_RW
		sd_card_stress_test
		;;
	6)
		info_view Extnal_Storage_RW
		ext_storage_stress_test ui
		;;
	7)
		info_view Ethernet
		network_stress_test
		;;
	8)
		info_view WiFi
		wifi_stress_test
		;;
	9)
		if [ $SOC_TYPE == "rockchip" ]; then
			info_view NPU
                	npu_stress_test
		else
			info_view UART loopback
			uart_stress_test ui
		fi
		;;
	10)
		info_view COMPORT
		uart_stress_test ui
#		uart_stress_test ui
		;;
	11)
                if [ $SOC_TYPE == "rockchip" ]; then
			info_view RTC
                        rtc_stress_test
		else
                        info_view TPU
                        tpu_stress_test
		fi
		;;
	12)
                if [ $SOC_TYPE == "rockchip" ]; then
			info_view EEPROM
                        eeprom_stress_test
		else
                        info_view CAN bus loopback
                        can_stress_test
		fi
		;;
	13)
                if [ $SOC_TYPE == "rockchip" ]; then
			info_view SIM
                        sim_stress_test
		else
                        info_view Audio recored/playback
                        audio_stress_test -a
		fi
		;;
	14)	
                if [ $SOC_TYPE == "rockchip" ]; then
                        info_view BLUETOOTH
                        bluetooth_stress_test
                else
                        info_view MCU DIO
                        mcu_dio_stress_test
                fi
                ;;
	15)
                if [ $SOC_TYPE == "rockchip" ]; then
                        info_view LT9211
                        lt9211_stress_test
                else
                        info_view MCU UART loopback
                        mcu_uart_stress_test
                fi
                ;;		
	16)
                if [ $SOC_TYPE == "rockchip" ]; then
                        info_view LED
                        led_test
                else
			info_view GPS
			gps_stress_test
                fi
                ;;	
	17)
                if [ $SOC_TYPE == "rockchip" ]; then
                        info_view USBHUB 
                        check_usbhub
                else
                        info_view AEM_Ethernet
                        aem_network_stress_test
                fi
                ;;
        18)
                info_view USBCC
                usbcc_stress_test
		;;
        19)
                info_view AUDIOLOOPBACK
                audio_stress_test
                ;;
        20)
                info_view AUDIOAMP
                audioamp_stress_test
                ;;

	*)
		check_system_status=true
		info_view BurnIn
		if [ "$DO_CPU_TEST" == "Y" ]; then
			cpu_freq_stress_test
		fi
		if [ "$DO_GPU_TEST" == "Y" ]; then
			gpu_test
		fi
		if [ "$DO_DDR_TEST" == "Y" ]; then
			ddr_test 32MB
		fi
		if [ "$DO_eMMC_TEST" == "Y" ]; then
			emmc_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_SD_TEST" == "Y" ];then
			sd_card_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_EXTERNALSTORAGE_TEST" == "Y" ]; then
			ext_storage_stress_test bk
		fi
		if [ "$DO_ETHERNET_TEST" == "Y" ]; then
			network_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_WIFI_TEST" == "Y" ]; then
			wifi_stress_test > /dev/null 2>&1 &
		fi
                if [ "$DO_BT_TEST" == "Y" ]; then
                        bluetooth_stress_test > /dev/null 2>&1 &
                fi
		if [ "$DO_UART_TEST" == "Y" ]; then
		    uart_stress_test bk
		fi
		if [ "$DO_TPU_TEST" == "Y" ]; then
			tpu_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_UART_to_UART_TEST" == "Y" ]; then
			uart_to_uart_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_CAN_TEST" == "Y" ]; then
			can_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_AUDIO_TEST" == "Y" ]; then
			audio_stress_test  > /dev/null 2>&1 &
		fi
                if [ "$DO_AUDIOAMP_TEST" == "Y" ]; then
                        audioamp_stress_test  > /dev/null 2>&1 &
                fi
		if [ "$DO_MCU_DIO_TEST" == "Y" ]; then
			mcu_dio_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_MCU_UART_TEST" == "Y" ]; then
			mcu_uart_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_GPS_TEST" == "Y" ]; then
			gps_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_AEM_ETHERNET_TEST" == "Y" ]; then
			aem_network_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_NPU_TEST" == "Y" ]; then
			npu_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_RTC_TEST" == "Y" ]; then
			rtc_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_EEPROM_TEST" == "Y" ]; then
			eeprom_stress_test > /dev/null 2>&1 &
		fi
		if [ "$DO_MODEM_TEST" == "Y" ]; then
			modem_stress_test > /dev/null 2>&1 &
		fi
                if [ "$DO_SIM_TEST" == "Y" ]; then
                        sim_stress_test > /dev/null 2>&1 &
                fi
		if [ "$DO_LT9211_TEST" == "Y" ]; then
			lt9211_stress_test > /dev/null 2>&1 &
		fi
                if [ "$DO_LED_TEST" == "Y" ]; then
                        led_test > /dev/null 2>&1 &
                fi
                if [ "$DO_USBHUB_CHECK" == "Y" ]; then
                        check_usbhub > /dev/null 2>&1 &
                fi
                if [ "$DO_USBCC_TEST" == "Y" ]; then
                        usbcc_stress_test > /dev/null 2>&1 &
                fi
                ;;
esac

sleep 2


while true; do
	end_sec=$(date +%s)
    diff=$(( $end_sec - $start_sec ))

    if [ $check_system_status == false ]; then
		exit
	fi
	get_device_info
	log ""
	log "============================================"
	log "$(date +'%Y/%m/%d/%H:%M:%S')"
	log "CPU Usage      = $cpu_usage"
	log "GPU Usage      = $gpu_usage"
	log "CPU temp       = $cpu_temp 'C"
	log "GPU temp       = $gpu_temp 'C"
	log "CPU freq       = $cpu_freq GHz"
	log "GPU freq       = $gpu_freq MHz"
	log "DDR freq       = $ddr_freq MHz"
	log ""
        log "$PROJECT test from $start_time, diff= $diff sec"
	log "Test Status"
	check_all_status
	log "============================================"
	log ""

	if [ "$SOC_TYPE" == "imx8" ]; then
		if dmesg -T | grep "xhci: HC died" > /dev/null
       			then
			#log "detect firmware hang"
			log "detect usb controller hang"
			ip -all netns delete
			killall iperf3 > /dev/null 2>&1
			killall check_network.sh > /dev/null 2>&1
			killall check_aem_network.sh > /dev/null 2>&1
			killall network_stress_test.sh > /dev/null 2>&1
			if [ "$DO_AEM_ETHERNET_TEST" == "Y" ]; then
				killall aem_network_stress_test.sh > /dev/null 2>&1
			fi
			killall gps_test.sh > /dev/null 2>&1
			sleep 60
			log "restart network stress test"
			network_stress_test > /dev/null 2>&1 &
			if [ "$DO_AEM_ETHERNET_TEST" == "Y" ]; then
				aem_network_stress_test > /dev/null 2>&1 &
			fi
			sleep 10
			dmesg -C
			log "restart network stress test done"
		else
			#log "not detect firmware hang"
			log "not detect usb controller hang"
		fi
	fi

	read -t 9 -p "Press 'q' for exit or Do nothing for keep testing: " RESP
	if [ "$RESP" == "q" ]; then
		kill_test
		sleep 1
		exit
	fi
	if [ "$SOC_TYPE" = "tegra" ] || [ "$SOC_TYPE" = "imx8" ]; then
                if [ $diff -ge $test_time ]; then
                        check_all_status
                        log "Time is up"
                        log "PASS"
                        sudo tar zcvf /home/asus/burn_in_log.tar.gz /var/log
                        sleep 10
                        sudo shutdown now
                        kill_test
                        #echo "PASS" > $top_path/logs/burn_in_result.txt
                        exit 0
                fi
        fi

done
