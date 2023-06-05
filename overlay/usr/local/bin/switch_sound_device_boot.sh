#!/bin/sh
# Config audio output devices at boot time
hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
jack_status=$(cat /sys/class/extcon/extcon4/cable.1/state)

if [ $hdmi_status = "connected" ] && [ $jack_status = 0 ];
then
	/bin/bash /etc/pulse/switch_sound_device.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
else
	/bin/bash /etc/pulse/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
fi
