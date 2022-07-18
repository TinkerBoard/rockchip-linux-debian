#!/bin/bash

echo "Update device.description for pulseaudio 12.2"
sleep 5
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd update-sink-proplist alsa_output.platform-dp-sound.stereo-fallback device.description="DP_SPDIF-Sound-Output"
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd update-sink-proplist alsa_output.platform-hdmi-sound.stereo-fallback device.description="HDMI-Sound-Output"
sound_ext_card_name=`sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd list-cards | grep -A 10 alsa_card.platform-sound-ext-card | grep alsa.card_name`
sound_ext_alsa_card_name=$(echo $sound_ext_card_name | cut -d" " -f 3)
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd update-sink-proplist alsa_output.platform-sound-ext-card.stereo-fallback device.description=$sound_ext_alsa_card_name

# set default sink output
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd set-default-sink "alsa_output.platform-hdmi-sound.stereo-fallback"

# check hdmi and dp connect status

hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
dp_status=$(cat /sys/class/drm/card0-DP-1/status)

echo "hdmi_status = $hdmi_status , dp_status = $dp_status"

if [ $hdmi_status = "connected" ]
then
	/etc/pulse/movesinks.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
elif [ $dp_status = "connected" ]
then
	/etc/pulse/movesinks.sh "alsa_output.platform-dp-sound.stereo-fallback"
else
	/etc/pulse/movesinks.sh "alsa_output_platform-hdmi-sound.stereo-fallback"
fi
