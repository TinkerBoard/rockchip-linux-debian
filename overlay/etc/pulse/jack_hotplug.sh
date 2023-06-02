#!/bin/bash

hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)

if [ "$1" == "1" ]; then
	echo "Plug-in headphone, set default sound card to RK809";
	/etc/pulse/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
fi

if [ "$1" == "0" ]; then
	if [ $hdmi_status = "connected" ]; then
		echo "Plug-out headphone, HDMI is connected, set default sound card to HDMI";
		/etc/pulse/switch_sound_device.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
	fi
	if [ $hdmi_status = "disconnected" ]; then
		echo "Plug-out headphone, HDMI is disconnected, set default sound card to RK809";
                /etc/pulse/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
	fi
fi
