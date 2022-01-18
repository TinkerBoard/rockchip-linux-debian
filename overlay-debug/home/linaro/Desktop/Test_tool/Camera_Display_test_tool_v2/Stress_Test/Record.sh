#!/bin/bash

i=0
ERROR=0
ResultFile="/tmp/Record_TestResult.txt"
CSI0="/dev/video0"
output="/tmp"

function Remove_TestResult()
{
    if [ -f $ResultFile ]; then
		echo "ResultFile EXIST, Revmove ResultFile!"
		rm -rf $ResultFile
	fi
}

function END()
{
    exit $ERROR
}

Remove_TestResult

if [ ! -n "$1" ];then
	echo -e "Set to default record time: 12 hr(s)" | tee -a $ResultFile
	time=$[12*1]
else
	echo -e "Set to default record time: $1 hr(s)" | tee -a $ResultFile
	time=$[$1*1]
fi

echo $time

echo -e "Start Record Test!" | tee -a $ResultFile
echo 60 > /tmp/flicker_mode
cat /sys/bus/i2c/drivers/imx219/1-0010/name |grep "imx219"
if [ "$?" == "0" ]; then
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[fmt:SRGGB10_1X10/1920x1080]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[crop:(0,0)/1920x1080]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[fmt:YUYV8_2X8/1920x1080]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[crop:(0,0)/1920x1080]'
	media-ctl -d /dev/media0 --set-v4l2 '"m00_b_imx219 1-0010":0[fmt:SRGGB10_1X10/1920x1080]'
	v4l2-ctl -d /dev/video0 --set-fmt-video=width=1920,height=1080,pixelformat=NV12 --set-crop=top=0,left=0,width=1920,height=1080
else
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[fmt:SBGGR8_1X8/1296x972]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[crop:(0,0)/1296x972]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[fmt:YUYV8_2X8/1296x972]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[crop:(0,0)/1296x972]'
	media-ctl -d /dev/media0 --set-v4l2 '"m00_b_ov5647 1-0036":0[fmt:SBGGR8_1X8/1296x972]'
	v4l2-ctl -d /dev/video0 --set-fmt-video=width=1296,height=972,pixelformat=NV12 --set-crop=top=0,left=0,width=1296,height=972
fi

while [ $i != $time ]; do
	i=$(($i+1))
	rm -rf $output/Record.avi
	echo -e "$(date): Start record $i time(s)" | tee -a $ResultFile
	gst-launch-1.0 v4l2src device=$CSI0 ! video/x-raw,width=640,height=480 ! tee name=t t. ! queue ! autovideosink sync=false t. ! queue ! mpph264enc ! queue ! h264parse ! mpegtsmux ! filesink location=$output/Record.ts &
	var=$!
	sleep 3600
	kill -9 $var
    echo -e "$(date): Camera record $i time(s)" | tee -a $ResultFile
done

echo -e "Finished Record Test!" | tee -a $ResultFile

read -p "Press enter to finish"