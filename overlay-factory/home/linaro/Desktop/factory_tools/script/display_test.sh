#!/bin/bash
export DISPLAY=:0.0
picture="$3"
i=0
ERROR=0
ResultFile="/tmp/DISPLAY_Result.txt"

#Previous_TinkerBoard_Video_Path="/home/linaro/Desktop/AA7Device/TestItem/Video/$video"
Previous_TinkerBoard_Image_Path="/home/linaro/Desktop/AA7Device/TestItem/Image/$picture"
#TinkerBoard_Video_Path="/home/linaro/Desktop/TinkerBoard/TestItem/Video/$video"
TinkerBoard_Image_Path="/home/linaro/Desktop/TinkerBoard/TestItem/Image/$picture"
#Tinker_EdgeR_Video_Path="/home/linaro/Desktop/TinkerEdgeR/TestItem/Video/$video"
Tinker_EdgeR_Image_Path="/home/linaro/Desktop/TinkerEdgeR/TestItem/Image/$picture"
#Tinker_II_Video_Path="/home/linaro/Desktop/TinkerII/TestItem/Video/$video"
Tinker_II_Image_Path="/home/linaro/Desktop/TinkerII/TestItem/Image/$picture"
#Tinker_EdgeT_Video_Path="/home/TinkerEdgeT/script/$video"
Tinker_EdgeT_Image_Path="/home/TinkerEdgeT/script/$picture"
#PE100A_Video_Path="/home/pe100a/script/Video/$video"
PE100A_Image_Path="/home/pe100a/script/Image/$picture"
#PV100A_Video_Path="/home/pv100a/script/Video/$video"
PV100A_Image_Path="/home/pv100a/script/Image/$picture"
#Blizzard_Video_Path="/home/blizzard/script/Video/$video"
Blizzard_Image_Path="/home/blizzard/script/Image/$picture"

#Tinker_3_Video_Path="/home/linaro/Desktop/factory_tools/files/Video/$video"
Tinker_3_Image_Path="/home/linaro/Desktop/factory_tools/files/Image/$picture"

function Remove_TestResult()
{
    if [ -f $ResultFile ]; then
		rm -rf $ResultFile
	fi
}

function END()
{
    exit $ERROR
}

function Pre_Tinker_Board_DSI()
{
	hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ $hdmi_status = "connected" ]; then
		su linaro -c "xrandr --output HDMI-1 --off"
		#su linaro -c "gst-launch-1.0 filesrc location=$Previous_TinkerBoard_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=80"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Previous_TinkerBoard_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=80"
		su linaro -c "xrandr --output HDMI-1 --auto"
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$Previous_TinkerBoard_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=80"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Previous_TinkerBoard_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=80"
	fi
}

function Pre_Tinker_Board_HDMI()
{
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ -d "/sys/class/drm/card0-DSI-1/" ]; then
		dsi_status=$(cat /sys/class/drm/card0-DSI-1/status)
		if [ $dsi_status = "connected" ]; then
			#su linaro -c "gst-launch-1.0 filesrc location=$Previous_TinkerBoard_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=82"
			su linaro -c "gst-launch-1.0 -v filesrc location=$Previous_TinkerBoard_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=82"
		fi
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$Previous_TinkerBoard_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=80"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Previous_TinkerBoard_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=80"
	fi
}

function Tinker_Board_DSI()
{
	hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ $hdmi_status = "connected" ]; then
		su linaro -c "xrandr --output HDMI-1 --off"
		#su linaro -c "gst-launch-1.0 filesrc location=$TinkerBoard_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=92"
		su linaro -c "gst-launch-1.0 -v filesrc location=$TinkerBoard_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=92"
		su linaro -c "xrandr --output HDMI-1 --auto"
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$TinkerBoard_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=92"
		su linaro -c "gst-launch-1.0 -v filesrc location=$TinkerBoard_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=92"
	fi
}

function Tinker_Board_HDMI()
{
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ -d "/sys/class/drm/card0-DSI-1/" ]; then
		dsi_status=$(cat /sys/class/drm/card0-DSI-1/status)
		if [ $dsi_status = "connected" ]; then
			#su linaro -c "gst-launch-1.0 filesrc location=$TinkerBoard_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=84"
			su linaro -c "gst-launch-1.0 -v filesrc location=$TinkerBoard_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=84"
		fi
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$TinkerBoard_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=84"
		su linaro -c "gst-launch-1.0 -v filesrc location=$TinkerBoard_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=84"
	fi
}

function Tinker_EdgeR_DSI()
{
	hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ $hdmi_status = "connected" ]; then
		su linaro -c "xrandr --output HDMI-1 --off"
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_EdgeR_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=91"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_EdgeR_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=91"
		su linaro -c "xrandr --output HDMI-1 --auto"
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_EdgeR_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=91"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_EdgeR_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=91"
	fi
}

function Tinker_EdgeR_HDMI()
{
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ -d "/sys/class/drm/card0-DSI-1/" ]; then
		dsi_status=$(cat /sys/class/drm/card0-DSI-1/status)
		if [ $dsi_status = "connected" ]; then
			#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_EdgeR_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=93"
			su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_EdgeR_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=93"
		fi
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_EdgeR_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=91"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_EdgeR_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=91"
	fi
}

function Tinker_II_DSI()
{
	hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ $hdmi_status = "connected" ]; then
		su linaro -c "xrandr --output HDMI-1 --off"
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_II_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=91"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_II_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=91"
		su linaro -c "xrandr --output HDMI-1 --auto"
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_II_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=91"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_II_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=91"
	fi
}

function Tinker_II_HDMI()
{
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ -d "/sys/class/drm/card0-DSI-1/" ]; then
		dsi_status=$(cat /sys/class/drm/card0-DSI-1/status)
		if [ $dsi_status = "connected" ]; then
			#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_II_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=93"
			su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_II_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=93"
		fi
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_II_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! rkximagesink connector-id=91"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_II_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! rkximagesink connector-id=91"

	fi
}

function Tinker_EdgeT_DSI()
{
	#gplay-1.0 --video-sink=waylandsink $Tinker_EdgeT_Video_Path
	gst-launch-1.0 filesrc location=$Tinker_EdgeT_Image_Path ! jpegdec ! imagefreeze ! waylandsink
}

function Tinker_EdgeT_HDMI()
{
	if [ -d "/sys/class/drm/card1-DSI-1/" ]; then
		dsi_status=$(cat /sys/class/drm/card1-DSI-1/status)
		if [ $dsi_status = "connected" ]; then
			#gplay-1.0 --video-sink=kmssink $Tinker_EdgeT_Video_Path
			gst-launch-1.0 filesrc location=$Tinker_EdgeT_Image_Path ! jpegdec ! imagefreeze ! kmssink
		fi
	else
		#gplay-1.0 --video-sink=waylandsink $Tinker_EdgeT_Video_Path
		gst-launch-1.0 filesrc location=$Tinker_EdgeT_Image_Path ! jpegdec ! imagefreeze ! waylandsink
	fi
}

function PE100A_DSI()
{
	#gst-launch-1.0 filesrc location=$PE100A_Video_Path typefind=true ! qtdemux name=demux ! queue max-size-time=0 ! vpudec ! queue max-size-time=0 ! waylandsink demux. ! queue ! beepdec ! audioconvert ! alsasink
	gst-launch-1.0 filesrc location=$PE100A_Image_Path ! jpegdec ! imagefreeze ! waylandsink
}

function PE100A_HDMI()
{
	if [ -d "/sys/class/drm/card1-DSI-1/" ]; then
		dsi_status=$(cat /sys/class/drm/card1-DSI-1/status)
		if [ $dsi_status = "connected" ]; then
			#gst-launch-1.0 filesrc location=$PE100A_Video_Path typefind=true ! qtdemux name=demux ! queue max-size-time=0 ! vpudec ! queue max-size-time=0 ! kmssink demux. ! queue ! beepdec ! audioconvert ! alsasink
			gst-launch-1.0 filesrc location=$PE100A_Image_Path ! jpegdec ! imagefreeze ! kmssink
		fi
	else
		#gst-launch-1.0 filesrc location=$PE100A_Video_Path typefind=true ! qtdemux name=demux ! queue max-size-time=0 ! vpudec ! queue max-size-time=0 ! waylandsink demux. ! queue ! beepdec ! audioconvert ! alsasink
		gst-launch-1.0 filesrc location=$PE100A_Image_Path ! jpegdec ! imagefreeze ! waylandsink
	fi
}

function PV100A_DSI()
{
	#gst-launch-1.0 filesrc location=$PV100A_Video_Path typefind=true ! qtdemux name=demux ! queue max-size-time=0 ! vpudec ! queue max-size-time=0 ! waylandsink demux. ! queue ! beepdec ! audioconvert ! alsasink
	gst-launch-1.0 filesrc location=$PV100A_Image_Path ! jpegdec ! imagefreeze ! waylandsink
}

function PV100A_HDMI()
{
	if [ -d "/sys/class/drm/card1-DSI-1/" ]; then
		dsi_status=$(cat /sys/class/drm/card1-DSI-1/status)
		if [ $dsi_status = "connected" ]; then
			#gst-launch-1.0 filesrc location=$PV100A_Video_Path typefind=true ! qtdemux name=demux ! queue max-size-time=0 ! vpudec ! queue max-size-time=0 ! kmssink demux. ! queue ! beepdec ! audioconvert ! alsasink
			gst-launch-1.0 filesrc location=$PV100A_Image_Path ! jpegdec ! imagefreeze ! kmssink
		fi
	else
		#gst-launch-1.0 filesrc location=$PV100A_Video_Path typefind=true ! qtdemux name=demux ! queue max-size-time=0 ! vpudec ! queue max-size-time=0 ! waylandsink demux. ! queue ! beepdec ! audioconvert ! alsasink
		gst-launch-1.0 filesrc location=$PV100A_Image_Path ! jpegdec ! imagefreeze ! waylandsink
	fi
}

function Blizzard_LVDS()
{
	sleep 1
	if [ -d "/sys/class/drm/card1-HDMI-A-1/" ]; then
		hdmi_status=$(cat /sys/class/drm/card1-HDMI-A-1/status)
		if [ $hdmi_status = "connected" ]; then
			echo "off" > /sys/class/drm/card1-HDMI-A-1/status
			sleep 1
		fi
	fi
	#gst-launch-1.0 filesrc location=$Blizzard_Video_Path typefind=true ! qtdemux name=demux ! queue max-size-time=0 ! vpudec ! queue max-size-time=0 ! waylandsink demux. ! queue ! beepdec ! audioconvert ! alsasink
	gst-launch-1.0 filesrc location=$Blizzard_Image_Path ! jpegdec ! imagefreeze ! waylandsink
	echo "on" > /sys/class/drm/card1-HDMI-A-1/status
}

function Blizzard_HDMI()
{
	sleep 1
	echo "off" > /sys/class/drm/card1-LVDS-1/status
	sleep 1
	#gst-launch-1.0 filesrc location=$Blizzard_Video_Path typefind=true ! qtdemux name=demux ! queue max-size-time=0 ! vpudec ! queue max-size-time=0 ! waylandsink demux. ! queue ! beepdec ! audioconvert ! alsasink
	gst-launch-1.0 filesrc location=$Blizzard_Image_Path ! jpegdec ! imagefreeze ! waylandsink
	echo "on" > /sys/class/drm/card1-LVDS-1/status
}

function Tinker_3_LVDS()
{
	hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ $hdmi_status = "connected" ]; then
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_3_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! kmssink connector-id=173"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_3_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! kmssink connector-id=173"
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_3_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! kmssink"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_3_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! kmssink"
	fi
}

function Tinker_3_EDP()
{
	hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ $hdmi_status = "connected" ]; then
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_3_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! kmssink connector-id=157"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_3_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! kmssink connector-id=157"
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_3_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! kmssink"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_3_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! kmssink"
	fi
}

function Tinker_3_HDMI()
{
	#su linaro -c "gst-launch-1.0 -v filesrc location=/home/linaro/Desktop/1.jpg ! jpegdec ! imagefreeze ! videoconvert ! autovideosink"
	if [ -d "/sys/class/drm/card0-DSI-1/" ]; then
		dsi_status=$(cat /sys/class/drm/card0-DSI-1/status)
		if [ $dsi_status = "connected" ]; then
			#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_3_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! kmssink connector-id=157"
			su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_3_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! kmssink connector-id=157"
		fi
	elif [ -d "/sys/class/drm/card0-eDP-1/" ]; then
		edp_status=$(cat /sys/class/drm/card0-eDP-1/status)
		if [ $edp_status = "connected" ]; then
			#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_3_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! kmssink connector-id=159"
			su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_3_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! kmssink connector-id=159"
		fi
	else
		#su linaro -c "gst-launch-1.0 filesrc location=$Tinker_3_Video_Path ! decodebin name=decoder decoder. ! queue ! audioconvert ! audioresample ! autoaudiosink decoder. ! videoconvert ! kmssink"
		su linaro -c "gst-launch-1.0 -v filesrc location=$Tinker_3_Image_Path ! jpegdec ! imagefreeze ! videoconvert ! kmssink"

	fi
}

Remove_TestResult

if [ "$1" == "1" ];then
	if [ "$2" == "DSI" ];then
		echo -e "Run previous Tinker Board DSI Test" | tee -a $ResultFile
		Pre_Tinker_Board_DSI
	elif [ "$2" == "HDMI" ];then
		echo -e "Run previous Tinker Board HDMI Test" | tee -a $ResultFile
		Pre_Tinker_Board_HDMI
	else
		echo -e "Error parameter, parameter two only can set DSI or HDMI !!" | tee -a $ResultFile
		END
	fi
elif [ "$1" == "2" ];then
	if [ "$2" == "DSI" ];then
		echo -e "Run Tinker Board DSI Test" | tee -a $ResultFile
		Tinker_Board_DSI
	elif [ "$2" == "HDMI" ];then
		echo -e "Run Tinker Board HDMI Test" | tee -a $ResultFile
		Tinker_Board_HDMI
	else
		echo -e "Error parameter, parameter two only can set DSI or HDMI !!" | tee -a $ResultFile
		END
	fi
elif [ "$1" == "3" ];then
	if [ "$2" == "DSI" ];then
		echo -e "Run Tinker Edge R DSI Test" | tee -a $ResultFile
		Tinker_EdgeR_DSI
	elif [ "$2" == "HDMI" ];then
		echo -e "Run Tinker Edge R HDMI Test" | tee -a $ResultFile
		Tinker_EdgeR_HDMI
	else
		echo -e "Error parameter, parameter two only can set DSI or HDMI !!" | tee -a $ResultFile
		END
	fi
elif [ "$1" == "4" ];then
	if [ "$2" == "DSI" ];then
		echo -e "Run Tinker II DSI Test" | tee -a $ResultFile
		Tinker_II_DSI
	elif [ "$2" == "HDMI" ];then
		echo -e "Run Tinker II HDMI Test" | tee -a $ResultFile
		Tinker_II_HDMI
	else
		echo -e "Error parameter, parameter two only can set DSI or HDMI !!" | tee -a $ResultFile
		END
	fi
elif [ "$1" == "5" ];then
	if [ "$2" == "DSI" ];then
		echo -e "Run Tinker Edge T DSI Test" | tee -a $ResultFile
		Tinker_EdgeT_DSI
	elif [ "$2" == "HDMI" ];then
		echo -e "Run Tinker Edge T HDMI Test" | tee -a $ResultFile
		Tinker_EdgeT_HDMI
	else
		echo -e "Error parameter, parameter two only can set DSI or HDMI !!" | tee -a $ResultFile
		END
	fi
elif [ "$1" == "6" ];then
	if [ "$2" == "DSI" ];then
		echo -e "Run PE100A DSI Test" | tee -a $ResultFile
		PE100A_DSI
	elif [ "$2" == "HDMI" ];then
		echo -e "Run PE100A HDMI Test" | tee -a $ResultFile
		PE100A_HDMI
	else
		echo -e "Error parameter, parameter two only can set DSI or HDMI !!" | tee -a $ResultFile
		END
	fi
elif [ "$1" == "7" ];then
	if [ "$2" == "DSI" ];then
		echo -e "Run PV100A DSI Test" | tee -a $ResultFile
		PV100A_DSI
	elif [ "$2" == "HDMI" ];then
		echo -e "Run PV100A HDMI Test" | tee -a $ResultFile
		PV100A_HDMI
	else
		echo -e "Error parameter, parameter two only can set DSI or HDMI !!" | tee -a $ResultFile
		END
	fi
elif [ "$1" == "8" ];then
	export XDG_RUNTIME_DIR=/run/user/$UID
	if [ "$2" == "LVDS" ];then
		echo -e "Run Blizzard LVDS Test" | tee -a $ResultFile
		Blizzard_LVDS
	elif [ "$2" == "HDMI" ];then
		echo -e "Run Blizzard HDMI Test" | tee -a $ResultFile
		Blizzard_HDMI
	else
		echo -e "Error parameter, parameter two only can set LVDS or HDMI !!" | tee -a $ResultFile
		END
	fi
elif [ "$1" == "9" ];then
	export XDG_RUNTIME_DIR=/run/user/$UID
	if [ "$2" == "LVDS" ];then
		echo -e "Run Tinker3 LVDS Test" | tee -a $ResultFile
		Tinker_3_LVDS
	elif [ "$2" == "HDMI" ];then
		echo -e "Run Tinker3 HDMI Test" | tee -a $ResultFile
		Tinker_3_HDMI
	elif [ "$2" == "EDP" ];then
		echo -e "Run Tinker3 EDP Test" | tee -a $ResultFile
		Tinker_3_EDP
	else
		echo -e "Error parameter, parameter two only can set LVDS or HDMI !!" | tee -a $ResultFile
		END
	fi
else
	echo -e "Cannot find item, please set below number!" | tee -a $ResultFile
	echo -e "1).Tinker board(Previous)"
	echo -e "2).Tinker board(New)"
	echo -e "3).Tinker Edge R"
	echo -e "4).Tinker II"
	echo -e "5).Tinker Edge T"
	echo -e "6).PE100A"
	echo -e "7).PV100A"
	echo -e "8).Blizzard"
	echo -e "9).Tinker3"
	END
fi
