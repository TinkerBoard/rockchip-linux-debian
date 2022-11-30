#!/bin/bash

#export XDG_RUNTIME_DIR="/run/user/0"
export DISPLAY=:0
#xhost local:$USER
if [ $1 == "imx8" ]; then
	gputool=glmark2-es2-wayland
elif [ $1 == "tegra" ]; then
	gputool=glmark2
elif [ $1 == "rockchip" ]; then
	gputool=glmark2-es2
fi
if [ ! -z "$2" ]; then
	background_num=$2
else
	background_num=2
fi

if [ $1 == "rockchip" ]; then
	sudo su -c "$gputool --benchmark refract --run-forever > /dev/null &"
else
	su asus -c "/usr/bin/xterm -display :0 -e '$gputool --benchmark terrain --run-forever' > /dev/null &"
fi

#$gputool --benchmark terrain --run-forever > /dev/null &
for ((i=1 ; i<=$background_num ; i++))
do
	#echo "gpu_stess.sh : $i"
#	$gputool --benchmark terrain --run-forever --off-screen > /dev/null &
#        sudo /usr/bin/xterm -display :0.0 $gputool
	if [ $1 == "rockchip" ]; then
		sudo su -c "$gputool --benchmark refract --run-forever --off-screen > /dev/null &"
	else
		su asus -c "/usr/bin/xterm -display :0 -e '$gputool --benchmark terrain --run-forever --off-screen' > /dev/null &"
	fi
	sleep 1
done
