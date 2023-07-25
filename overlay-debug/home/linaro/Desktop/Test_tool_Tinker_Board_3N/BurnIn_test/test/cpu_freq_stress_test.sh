#!/bin/bash
echo "test will run $1 seconds"

while [ 1!=2 ]
do
	Flag=$(ps aux | grep "stressapp" | grep -v "grep")

	echo "stresstestapp status:$Flag"
	if [ "$Flag" == "" ]
	then
		cpu_num=$(ls /sys/devices/system/cpu/ | grep cpu[0-9] | wc -l)
		echo "$1/test/stressapptest -s $2 -C $cpu_num --pause_delay 3600 --pause_duration 1 -W --stop_on_errors  -M 32"

		$1/test/stressapptest -s $2 -C $cpu_num --pause_delay 3600 --pause_duration 1 -W --stop_on_errors  -M 32 > $3 &

	fi
	sleep 20
done
exit 0

