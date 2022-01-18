#!/bin/bash

i=0
ERROR=0
ResultFile="/tmp/Capture_TestResult.txt"
CSI0="/dev/video0"
output="/tmp"

function Remove_TestResult()
{
    if [ -f $ResultFile ]; then
		echo "$ResultFile EXIST, Revmove $ResultFile!"
		rm -rf $ResultFile
	fi
	
	rm -rf /tmp//*.jpg
}

function END()
{
    exit $ERROR
}

Remove_TestResult

if [ ! -n "$1" ];then
	echo -e "Set to default capture 3000 shots" | tee -a $ResultFile
	count=$((3000))
else
	echo -e "Set to capture $1 shots" | tee -a $ResultFile
	count=$(($1))
fi

echo -e "Start Capture Stress Test!" | tee -a $ResultFile
echo 60 > /tmp/flicker_mode
cat /sys/bus/i2c/drivers/imx219/1-0010/name |grep "imx219"
if [ "$?" == "0" ]; then
	echo -e "Start Preview Test!" | tee -a $ResultFile
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[fmt:SRGGB10_1X10/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[crop:(0,0)/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[fmt:YUYV8_2X8/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[crop:(0,0)/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"m00_b_imx219 1-0010":0[fmt:SRGGB10_1X10/3280x2464]'
	v4l2-ctl -d /dev/video0 --set-fmt-video=width=3280,height=2464,pixelformat=NV12 --set-crop=top=0,left=0,width=3280,height=2464
else
	echo -e "Start Preview Test!" | tee -a $ResultFile
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[fmt:SBGGR8_1X8/2592x1944]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[crop:(0,0)/2592x1944]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[fmt:YUYV8_2X8/2592x1944]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[crop:(0,0)/2592x1944]'
	media-ctl -d /dev/media0 --set-v4l2 '"m00_b_ov5647 1-0036":0[fmt:SBGGR8_1X8/2592x1944]'
	v4l2-ctl -d /dev/video0 --set-fmt-video=width=2592,height=1944,pixelformat=NV12 --set-crop=top=0,left=0,width=2592,height=1944
fi

echo -e "Start Capture Test!" | tee -a $ResultFile
while [ $i != $count ]; do
    i=$(($i+1))

	cat /sys/bus/i2c/drivers/imx219/1-0010/name |grep "imx219"
	if [ "$?" == "0" ]; then
		gst-launch-1.0 v4l2src device=$CSI0 num-buffers=10 ! video/x-raw,format=NV12,width=3280,height=2464 ! jpegenc ! multifilesink location=$output/imx219_$i.jpg
	else
		gst-launch-1.0 v4l2src device=$CSI0 num-buffers=10 ! video/x-raw,format=NV12,width=2592,height=1944 ! jpegenc ! multifilesink location=$output/ov5647_$i.jpg
	fi
	echo -e "$(date): Camera capture $i time(s)" | tee -a $ResultFile
			
done
echo -e "Finished Capture Test!" | tee -a $ResultFile

read -p "Press enter to finish"