#!/bin/sh
# Config audio output devices at boot time
hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
jack_tb3n_status=$(cat /sys/class/extcon/extcon4/cable.1/state)
jack_tb3_status=$(cat /sys/class/extcon/extcon3/cable.1/state)

if [ $jack_tb3n_status = 0 ] || [ $jack_tb3_status = 0 ];
then
	if [ $hdmi_status = "connected" ];
	then
		echo "HDMI is connected, set default sound card to HDMI"
		/bin/bash /etc/pulse/switch_sound_device.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
	fi
else
	echo "audio jack is connected, set default sound card to RK809"
	/bin/bash  /etc/pulse/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
fi
