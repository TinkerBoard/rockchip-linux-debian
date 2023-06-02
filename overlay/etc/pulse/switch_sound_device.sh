#!/bin/bash

# Switch sound device
echo "Config default sound output device: $1";
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd set-default-sink $1

# If you're playing sounds, switch running stream to your specified output.
echo "Switch running actvice stream to another sound output device"
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd list-sink-inputs | grep index | while read line
do
echo "Playback is running, find current stream index number";
echo $line | cut -f2 -d' ';
echo "Move this running stream to sink: $1";
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd move-sink-input `echo $line | cut -f2 -d' '` $1

done
