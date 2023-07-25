#!/bin/sh
echo "Delect power.txt"
test_time=$1
rm power.txt
#SOM identification
#25 (xavier -NX)
#33 (Nano)
#24 (TX2 -NX)
chipid=$(cat /sys/module/tegra_fuse/parameters/tegra_chip_id)
if [ "$chipid" == "25" ]; then 
	SOM=NX
elif [ "$chipid" == "33" ]; then 
	SOM=NANO
elif [ "$chipid" == "24" ]; then 
	SOM=TX2NX
fi

echo "==============================================="
echo "$SOM power log will start after 3 seconds."
echo "It logs power every 1 second for $test_time sec."
echo "==============================================="
sleep 3
b=0
c=0
while [ $b -lt $test_time ]
do
	if [ "$chipid" == "25" ]; then 
		a=`sudo cat /sys/bus/i2c/drivers/ina3221x/7-0040/iio:device0/in_power0_input`
	elif [ "$chipid" == "33" ]; then 
		a=`sudo cat /sys/bus/i2c/drivers/ina3221x/6-0040/iio:device0/in_power0_input`
	elif [ "$chipid" == "24" ]; then 
		a=`sudo cat /sys/bus/i2c/drivers/ina3221x/2-0040/iio:device0/in_power0_input`
	fi
echo "$a" >> power.txt
echo "$a"
c=$(($a+$c))     
sleep 1
b=$(($b+1))
done
val=$(($c/$test_time))    
echo "DONE!!, Average:$val" | tee -a power.txt

