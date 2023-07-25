#!/bin/bash
# For PE1000N
# eqos: NX/TX2 SOM LAN (near power)
# r8168: NANO SOM LAN
# r8152: on board USB LAN
# igb: AEM-LAN

logfile=$1
flag=0
failcount1=0
passcount1=0
failcount2=0
passcount2=0
failcount3=0
passcount3=0
failcount4=0
passcount4=0
eth0_addr=192.168.100.100
eth1_addr=192.168.100.99
eth2_addr=192.168.200.100
eth3_addr=192.168.200.99
MODEL=`cat /proc/boardinfo | awk -v FS='/' '{print $1"_"$2}'`
SOM_ETH=""
AEM1_ETH=""
AEM2_ETH=""
USB_ETH=""
AEM_TAG=0
function Check_ETH_Number()
{
	CHECK_DRIVER=`sudo ethtool -i $1 | grep driver | awk '{print $2}'`
	if [[ $CHECK_DRIVER == "r8168" ]] || [[ $CHECK_DRIVER == "eqos" ]]; then
		SOM_ETH=$1
	elif [[ $CHECK_DRIVER == "igb" ]]; then
		if [[ $AEM_TAG -eq 0 ]]; then
			AEM1_ETH=$1
			AEM_TAG=1
		else
			AEM2_ETH=$1
		fi
	elif [[ $CHECK_DRIVER == "r8152" ]]; then
		USB_ETH=$1
	fi
}
Check_ETH_Number "eth0"
Check_ETH_Number "eth1"
Check_ETH_Number "eth2"
Check_ETH_Number "eth3"

echo "Model:$MODEL SOM_ETH($SOM_ETH) USB_ETH($USB_ETH) AEM1_ETH($AEM1_ETH) AEM2_ETH($AEM2_ETH)" | tee -a $logfile

nslist=$(ip netns list)
if [ "$nslist" == "" ]
then

	if [ "$SOM_ETH" == "" ]
	then
		echo "SOM_ETH($SOM_ETH) not exist" | tee -a $logfile
		exit
	elif [ "$USB_ETH" == "" ]
	then
		echo "USB_ETH($USB_ETH) not exist" | tee -a $logfile
		exit
	elif [ "$AEM1_ETH" == "" ]
	then
		echo "AEM1_ETH($AEM1_ETH) not exist" | tee -a $logfile
		exit
	elif [ "$AEM2_ETH" == "" ]
	then
		echo "AEM2_ETH($AEM2_ETH) not exist" | tee -a $logfile
		exit
	fi
	
	ip netns add ns_server
	ip netns add ns_client
	ip netns add ns_server2
	ip netns add ns_client2
	ip link set $SOM_ETH netns ns_server
	ip netns exec ns_server ip addr add dev $SOM_ETH $eth0_addr/24
	ip netns exec ns_server ip link set dev $SOM_ETH up
	ip link set $USB_ETH netns ns_client
	ip netns exec ns_client ip addr add dev $USB_ETH $eth1_addr/24
	ip netns exec ns_client ip link set dev $USB_ETH up
	ip netns exec ns_server route add default gw 192.168.100.1
	ip netns exec ns_client route add default gw 192.168.100.1


	ip link set $AEM1_ETH netns ns_server2
	ip netns exec ns_server2 ip addr add dev $AEM1_ETH $eth2_addr/24
	ip netns exec ns_server2 ip link set dev $AEM1_ETH up
	ip link set $AEM2_ETH netns ns_client2
	ip netns exec ns_client2 ip addr add dev $AEM2_ETH $eth3_addr/24
	ip netns exec ns_client2 ip link set dev $AEM2_ETH up
	ip netns exec ns_server2 route add default gw 192.168.200.1
	ip netns exec ns_client2 route add default gw 192.168.200.1
	sleep 6
fi

while [ 1 != 2 ]
do
	if [ "$flag" == 0  ]
	then
		echo
		echo
		echo "============================================================"
		echo "	$MODEL AEM1_ETH($AEM1_ETH) Tx -> AEM2_ETH($AEM2_ETH)  Rx Start "
		echo "          $logfile"
		ip netns exec ns_client2 iperf3 --one-off -s -B "$eth3_addr" -i 10 &
		sleep 2
		ret=$(ip netns exec ns_server2 iperf3 -c "$eth3_addr" -B "$eth2_addr" -i 10 -t 30 --connect-timeout 3000 --rcv-timeout 3000 | grep Done)
		if [ "$ret" == "" ]
		then
			((failcount3+=1))
		else
			((passcount3+=1))
		fi

		echo "============================================================"
		echo "failcount3=$failcount3, failcount4=$failcount4, passcount3=$passcount3, passcount4=$passcount4" | tee -a $logfile
		echo
		echo
		sleep 3
	
		echo
		echo
		echo "============================================================"
		echo "	$MODEL AEM2_ETH($AEM2_ETH)  Tx -> AEM1_ETH($AEM1_ETH)  Rx Start "
		echo "          $logfile"
		ip netns exec ns_client2 iperf3 --one-off -s -B "$eth3_addr" -i 10 &
		sleep 2
		ret=$(ip netns exec ns_server2 iperf3 -c "$eth3_addr" -B "$eth2_addr" -i 10 -t 30 -R --connect-timeout 3000 --rcv-timeout 3000 | grep Done)
		if [ "$ret" == "" ]
		then
			((failcount4+=1))
		else
			((passcount4+=1))
		fi
		flag=1
		echo "============================================================"
		echo "failcount3=$failcount3, failcount4=$failcount4, passcount3=$passcount3, passcount4=$passcount4" | tee -a $logfile
		echo
		echo
		sleep 3

	else 
		echo
		echo
		echo "============================================================"
		echo "	$MODEL SOM_ETH($SOM_ETH)  Tx -> USB_ETH($USB_ETH)  Rx Start "
		echo "          $logfile"
		ip netns exec ns_client iperf3 --one-off -s -B "$eth1_addr" -i 10 &
		sleep 2
		ret=$(ip netns exec ns_server iperf3 -c "$eth1_addr" -B "$eth0_addr" -i 10 -t 30 --connect-timeout 3000 --rcv-timeout 3000 | grep Done)
		if [ "$ret" == "" ]
		then
			((failcount1+=1))
		else
			((passcount1+=1))
		fi
		echo "============================================================"
		echo "failcount1=$failcount1, failcount2=$failcount2, passcount1=$passcount1, passcount2=$passcount2" | tee -a $logfile
		echo
		echo
		sleep 3
	
		echo
		echo
		echo "============================================================"
		echo "	$MODEL USB_ETH($USB_ETH)  Tx -> SOM_ETH($SOM_ETH)  Rx Start "
		echo "          $logfile"
		ip netns exec ns_client iperf3 --one-off -s -B "$eth1_addr" -i 10 &
		sleep 2
		ret=$(ip netns exec ns_server iperf3 -c "$eth1_addr" -B "$eth0_addr" -i 10 -t 30 -R --connect-timeout 3000 --rcv-timeout 3000 | grep Done)
		if [ "$ret" == "" ]
		then
			((failcount2+=1))
		else
			((passcount2+=1))
		fi
		flag=0
		echo "============================================================"
		echo "failcount1=$failcount1, failcount2=$failcount2, passcount1=$passcount1, passcount2=$passcount2" | tee -a $logfile
		echo
		echo
		sleep 3
	fi

	if [ "$failcount1" -ge 5  ] || [ "$failcount2" -ge 5  ] || [ "$failcount3" -ge 5  ] || [ "$failcount4" -ge 5  ]
	then
		echo "network tansmissoin fail over 20 times." | tee -a $logfile
		echo "AEM1_ETH($AEM1_ETH) TX pass time = $passcount1 fail time $failcount1 " | tee -a $logfile
		echo "AEM2_ETH($AEM2_ETH) TX pass time = $passcount2 fail time $failcount2 " | tee -a $logfile
		echo "SOM_ETH($SOM_ETH) TX pass time = $passcount3 fail time $failcount3 " | tee -a $logfile
		echo "USB_ETH($USB_ETH) TX pass time = $passcount4 fail time $failcount4 " | tee -a $logfile
		exit
	fi

done
