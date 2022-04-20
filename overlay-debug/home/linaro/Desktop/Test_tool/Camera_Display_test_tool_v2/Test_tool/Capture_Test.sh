#!/bin/bash

i=0
ERROR=0
ResultFile="/tmp/Capture_TestResult.txt"
CSI0="/dev/video0"

function Remove_TestResult()
{
    if [ -f $ResultFile ]; then
		echo "$ResultFile EXIST, Revmove $ResultFile!"
		rm -rf $ResultFile
	fi
}

function END()
{
    exit $ERROR
}

Remove_TestResult

echo 60 > /tmp/flicker_mode
echo -e "Start Preview Test!" | tee -a $ResultFile
cat /sys/bus/i2c/drivers/imx219/1-0010/name |grep "imx219"
if [ "$?" == "0" ]; then
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[fmt:SRGGB10_1X10/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[crop:(0,0)/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[fmt:YUYV8_2X8/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[crop:(0,0)/3280x2464]'
	media-ctl -d /dev/media0 --set-v4l2 '"m00_b_imx219 1-0010":0[fmt:SRGGB10_1X10/3280x2464]'
	v4l2-ctl -d /dev/video0 --set-fmt-video=width=3280,height=2464,pixelformat=NV12 --set-crop=top=0,left=0,width=3280,height=2464
	gst-launch-1.0 v4l2src device=$CSI0 num-buffers=100 ! video/x-raw,format=NV12,width=1640,height=1232 ! videoconvert ! autovideosink
	echo -e "Start Capture Test!" | tee -a $ResultFile
	gst-launch-1.0 v4l2src device=$CSI0 num-buffers=10 ! video/x-raw,format=NV12,width=3280,height=2464 ! jpegenc ! multifilesink location=/tmp/Capture.jpg
else
	cat /sys/bus/i2c/drivers/imx477/1-001a/name |grep "imx477"
	if [ "$?" == "0" ]; then
		media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[fmt:SRGGB12_1X12/4056x3040]'
		media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[crop:(0,0)/4056x3040]'
		media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[fmt:YUYV8_2X8/4056x3040]'
		media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[crop:(0,0)/4056x3040]'
		media-ctl -d /dev/media0 --set-v4l2 '"m00_b_imx477 1-001a":0[fmt:SRGGB12_1X12/4056x3040]'
		v4l2-ctl -d /dev/video0 --set-fmt-video=width=4056,height=3040,pixelformat=NV12 --set-crop=top=0,left=0,width=4056,height=3040
		gst-launch-1.0 v4l2src device=$CSI0 num-buffers=100 ! video/x-raw,format=NV12,width=4056,height=3040 ! videoconvert ! autovideosink
		echo -e "Start Capture Test!" | tee -a $ResultFile
		gst-launch-1.0 v4l2src device=$CSI0 num-buffers=10 ! video/x-raw,format=NV12,width=4056,height=3040 ! jpegenc ! multifilesink location=/tmp/Capture.jpg
	else
		media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[fmt:SBGGR8_1X8/2592x1944]'
		media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":0[crop:(0,0)/2592x1944]'
		media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[fmt:YUYV8_2X8/2592x1944]'
		media-ctl -d /dev/media0 --set-v4l2 '"rkisp1-isp-subdev":2[crop:(0,0)/2592x1944]'
		media-ctl -d /dev/media0 --set-v4l2 '"m00_b_ov5647 1-0036":0[fmt:SBGGR8_1X8/2592x1944]'
		v4l2-ctl -d /dev/video0 --set-fmt-video=width=2592,height=1944,pixelformat=NV12 --set-crop=top=0,left=0,width=2592,height=1944
		gst-launch-1.0 v4l2src device=$CSI0 num-buffers=100 ! video/x-raw,format=NV12,width=1280,height=960 ! videoconvert ! autovideosink
		echo -e "Start Capture Test!" | tee -a $ResultFile
		gst-launch-1.0 v4l2src device=$CSI0 num-buffers=10 ! video/x-raw,format=NV12,width=2592,height=1944 ! jpegenc ! multifilesink location=/tmp/Capture.jpg
	fi
fi

echo -e "Finished Capture Test!" | tee -a $ResultFile

read -p "Press enter to finish"
