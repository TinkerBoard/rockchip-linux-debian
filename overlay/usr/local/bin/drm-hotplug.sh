#!/bin/bash -x

export DISPLAY=${DISPLAY:-:0}

HDMI="HDMI-1"
DP="DP-1"

HDMI_SYS="/sys/class/drm/card0-HDMI-A-1"
DP_SYS="/sys/class/drm/card0-DP-1"

HDMI_XRANDR_CONFIG="/boot/display/hdmi/xrandr.cfg"
DP_XRANDR_CONFIG="/boot/display/dp/xrandr.cfg"

HDMI_HOTPLUG_CONFIG="/boot/display/hdmi/hdmi_plug_flag.cfg"
DP_HOTPLUG_CONFIG="/boot/display/dp/dp_plug_flag.cfg"
HDMI_BOOT_FLAG="/boot/display/hdmi/hdmi_boot_flag.cfg"
DP_BOOT_FLAG="/boot/display/dp/dp_boot_flag.cfg"

HDMI_MODES_NODE="$HDMI_SYS/modes"
DP_MODES_NODE="$DP_SYS/modes"
HDMI_ENABLED_NODE="$HDMI_SYS/enabled"
DP_ENABLED_NODE="$DP_SYS/enabled"

HDMI_MODE_NODE="$HDMI_SYS/mode"
DP_MODE_NODE="$DP_SYS/mode"

hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
dp_status=$(cat /sys/class/drm/card0-DP-1/status)

#Save resolution if the external display is disconnected
#HDMI
if [ $hdmi_status = "disconnected" ]; then
	if [ -f $HDMI_HOTPLUG_CONFIG ]; then
		if [ "$(cat $HDMI_HOTPLUG_CONFIG)" != "Plug_Out" ]; then
			#if [ "$(cat $HDMI_MODES_NODE)" != "" ]; then
				HDMI_SAVE_MODE=$(su $user -c xrandr | grep HDMI | awk '{print$3}' | awk -F '+' '{print$1}')
				su $user -c "echo $HDMI_SAVE_MODE" > $HDMI_XRANDR_CONFIG
			#fi
		fi
	fi
	sudo xrandr --output $HDMI --off
	su $user -c "echo Plug_Out" > $HDMI_HOTPLUG_CONFIG
fi

#DP
if [ $dp_status = "disconnected" ]; then
	if [ -f $DP_HOTPLUG_CONFIG ]; then
		if [ "$(cat $DP_HOTPLUG_CONFIG)" != "Plug_Out" ]; then
			#if [ "$(cat $DP_MODES_NODE)" != "" ]; then
				DP_SAVE_MODE=$(su $user -c xrandr | grep DP | awk '{print$4}' | awk -F '+' '{print$1}')
				su $user -c "echo $DP_SAVE_MODE" > $DP_XRANDR_CONFIG
			#fi
		fi
	fi
	sudo xrandr --output $DP --off
	su $user -c "echo Plug_Out" > $DP_HOTPLUG_CONFIG
fi

#Restore external display preview resolution
#HDMI
#sudo -u $user xrandr
if [ $hdmi_status = "connected" ]; then
	if [ -f $HDMI_HOTPLUG_CONFIG ]; then
		if [ "$(cat $HDMI_HOTPLUG_CONFIG)" = "Plug_Out" ]; then
			#if [ "$(cat $HDMI_MODES_NODE)" != "" ]; then
			#	HDMI_SAVE_MODE=$(su $user -c xrandr | grep HDMI | awk '{print$3}' | awk -F '+' '{print$1}')
			#	su $user -c "echo $HDMI_SAVE_MODE" > $HDMI_XRANDR_CONFIG
			#fi
			if [ -f $HDMI_XRANDR_CONFIG ]; then
				if grep -q $(cat $HDMI_XRANDR_CONFIG) $HDMI_MODES_NODE; then
					sudo xrandr --output $HDMI --mode $(cat $HDMI_XRANDR_CONFIG)
				else
					sudo xrandr --output $HDMI --auto
				fi
			else
				sudo xrandr --output $HDMI --auto
			fi
		else
			if [ "$(cat $HDMI_XRANDR_CONFIG)" = "" ]; then
				if [ "$(cat $HDMI_BOOT_FLAG)" = "1" ]; then
					#don't do anything, system will handle it itself when booting with cable
					su $user -c "echo 0" > $HDMI_BOOT_FLAG
				else
					if [ "$(cat $HDMI_ENABLED_NODE)" != "enabled" ]; then
						#if boot without cable, display blank when first time plug in, we need to turn it on
						sudo xrandr --output $HDMI --auto
					fi
				fi
			fi
		fi
	fi
	su $user -c "echo Plug_In" > $HDMI_HOTPLUG_CONFIG
fi

#DP
if [ $dp_status = "connected" ]; then
	if [ -f $DP_HOTPLUG_CONFIG ]; then
		if [ "$(cat $DP_HOTPLUG_CONFIG)" = "Plug_Out" ]; then
			#if [ "$(cat $DP_MODES_NODE)" != "" ]; then
			#	DP_SAVE_MODE=$(su $user -c xrandr | grep DP | awk '{print$4}' | awk -F '+' '{print$1}')
			#	su $user -c "echo $DP_SAVE_MODE" > $DP_XRANDR_CONFIG
			#fi
			if [ -f $DP_XRANDR_CONFIG ]; then
				if grep -q $(cat $DP_XRANDR_CONFIG) $DP_MODES_NODE; then
					sudo xrandr --output $DP --mode $(cat $DP_XRANDR_CONFIG)
				else
					sudo xrandr --output $DP --auto
				fi
			else
				sudo xrandr --output $DP --auto
			fi
		else
			if [ "$(cat $DP_XRANDR_CONFIG)" = "" ]; then
				if [ "$(cat $DP_BOOT_FLAG)" = "1" ]; then
					#don't do anything, system will handle it itself when booting with cable
					su $user -c "echo 0" > $DP_BOOT_FLAG
				else
					if [ "$(cat $DP_ENABLED_NODE)" != "enabled" ]; then
						#if boot without cable, display blank when first time plug in, we need to turn it on
						sudo xrandr --output $DP --auto
					fi
				fi
			fi
		fi
	fi
	su $user -c "echo Plug_In" > $DP_HOTPLUG_CONFIG
fi

# Audio : switch audio output devices when HDMI or DP hot-plug

hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
dp_status=$(cat /sys/class/drm/card0-DP-1/status)

echo "Hot-Plug : hdmi_status = $hdmi_status, dp_status = $dp_status"

if [ $hdmi_status = "connected" ]
then
	/etc/pulse/movesinks.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
elif [ $dp_status = "connected" ]
then
	/etc/pulse/movesinks.sh "alsa_output.platform-dp-sound.stereo-fallback"
else
	/etc/pulse/movesinks.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
fi

exit 0
