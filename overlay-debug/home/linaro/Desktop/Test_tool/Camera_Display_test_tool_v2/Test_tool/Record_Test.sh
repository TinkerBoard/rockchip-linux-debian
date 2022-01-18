#!/bin/bash

i=0
ERROR=0
ResultFile="/tmp/Record_TestResult.txt"
CSI0="/dev/video0"

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
time=2
echo -e "Start Record Test!" | tee -a $ResultFile
echo 60 > /tmp/flicker_mode
cat /sys/bus/i2c/drivers/imx219/1-0010/name |grep "imx219"
if [ "$?" == "0" ]; then
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[fmt:SRGGB10_1X10/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[crop:(0,0)/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[fmt:YUYV8_2X8/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[crop:(0,0)/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"m00_b_imx219 1-0010":0[fmt:SRGGB10_1X10/3280x2464]'
	v4l2-ctl -d /dev/video0 --set-fmt-video=width=3280,height=2464,pixelformat=NV12 --set-crop=top=0,left=0,width=3280,height=2464
else
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[fmt:SBGGR8_1X8/2592x1944]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[crop:(0,0)/2592x1944]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[fmt:YUYV8_2X8/2592x1944]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[crop:(0,0)/2592x1944]'
	media-ctl -d /dev/media0 --set-v4l2 '"m00_b_ov5647 1-0036":0[fmt:SBGGR8_1X8/2592x1944]'
	v4l2-ctl -d /dev/video0 --set-fmt-video=width=2592,height=1944,pixelformat=NV12 --set-crop=top=0,left=0,width=2592,height=1944
fi

gst-launch-1.0 v4l2src device=$CSI0 ! video/x-raw,width=640,height=480 ! tee name=t t. ! queue ! autovideosink sync=false t. ! queue ! mpph264enc ! queue ! h264parse ! mpegtsmux ! filesink location=/tmp/Record_480p.ts &
var=$!
sleep 60
kill -9 $var
echo -e "$(date): Camera record Record_480p.avi" | tee -a $ResultFile

gst-launch-1.0 v4l2src device=$CSI0 ! video/x-raw,width=1280,height=720 ! tee name=t t. ! queue ! autovideosink sync=false t. ! queue ! mpph264enc ! queue ! h264parse ! mpegtsmux ! filesink location=/tmp/Record_720p.ts &
var=$!
sleep 60
kill -9 $var
echo -e "$(date): Camera record Record_720p.avi" | tee -a $ResultFile

gst-launch-1.0 v4l2src device=$CSI0 ! video/x-raw,width=1920,height=1088 ! tee name=t t. ! queue ! autovideosink sync=false t. ! queue ! mpph264enc ! queue ! h264parse ! mpegtsmux ! filesink location=/tmp/Record_1080p.ts &
var=$!
sleep 60
kill -9 $var
echo -e "$(date): Camera record Record_1080p.avi" | tee -a $ResultFile

echo -e "Finished Record Test!" | tee -a $ResultFile

read -p "Press enter to finish"