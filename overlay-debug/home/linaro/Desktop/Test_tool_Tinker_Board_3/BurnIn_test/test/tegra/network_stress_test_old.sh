#!/bin/bash

logfile=$1
flag=0
failcount1=0
passcount1=0
failcount2=0
passcount2=0
eth0_addr=192.168.100.100
eth1_addr=192.168.100.99

nslist=$(ip netns list)
if [ "$nslist" == "" ]
then
	eth0=$(ifconfig eth0 | grep "eth0")
	eth1=$(ifconfig eth1 | grep "eth1")
	if [ "$eth0" == "" ]
	then
		echo "eth0 not exist" | tee -a $logfile
		exit
	elif [ "$eth1" == "" ]
	then
		echo "eth1 not exist" | tee -a $logfile
		exit
	fi

	ip netns add ns_server
	ip netns add ns_client
	ip link set eth0 netns ns_server
	ip netns exec ns_server ip addr add dev eth0 $eth0_addr/24
	ip netns exec ns_server ip link set dev eth0 up
	ip link set eth1 netns ns_client
	ip netns exec ns_client ip addr add dev eth1 $eth1_addr/24
	ip netns exec ns_client ip link set dev eth1 up

	ip netns exec ns_server route add default gw 192.168.100.1
	ip netns exec ns_client route add default gw 192.168.100.1
	sleep 6
fi

while [ 1 != 2 ]
do
	if [ "$flag" == 0  ]
	then
		echo
		echo
		echo "============================================================"
		echo "		LAN1 Tx -> LAN2 Rx Start "
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
		flag=1
		echo "============================================================"
		echo "failcount1=$failcount1, failcount2=$failcount2, passcount1=$passcount1, passcount2=$passcount2" | tee -a $logfile
		echo
		echo
		sleep 3
	else
		echo
		echo
		echo "============================================================"
		echo "		LAN2 Tx -> LAN1 Rx Start "
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

	if [ "$failcount1" -ge 5  ] || [ "$failcount2" -ge 5  ]
	then
		echo "network tansmissoin fail over 20 times." | tee -a $logfile
		echo "LAN1 TX pass time = $passcount1 fail time $failcount1 " | tee -a $logfile
		echo "LAN2 TX pass time = $passcount2 fail time $failcount2 " | tee -a $logfile
		exit
	fi

done
