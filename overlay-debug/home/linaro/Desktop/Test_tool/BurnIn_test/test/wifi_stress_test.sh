#!/bin/bash
SOC_TYPE=$3
logfile=$2
if [ $SOC_TYPE == "rockchip" ]; then
	wlan_interface=wlp1s0
else
	wlan_intreface=wlan0
fi

echo "wifi_interface: $wlan_interface"

log()
{
        echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $logfile
}
#wifi_gw=$(route -n | grep $wlan_interface | grep UG | awk {'printf $2'})

sleep 3
pass_cnt=0
fail_cnt=0
while [ 1 != 2 ]
do
	wlan=$(ifconfig | grep $wlan_interface)

        if [ ! -z "$wlan" ]; then
                ((pass_cnt+=1))
                log "pass_cnt=$pass_cnt"
		fail_cnt=0

	else
                echo "$wlan_interface not exist" | tee -a $logfile
                ((fail_cnt+=1))
                log "$wlan_interface not exist"
                log "fail_cnt=$fail_cnt"
        fi

        if [ "$fail_cnt" -ge 6  ]; then
                log "wifi pass_cnt = $pass_cnt fail_cnt $fail_cnt "
                exit
        fi

	sleep 2
done
