#!/bin/bash

echo "Setting default sink to: $1";
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd set-default-sink $1
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd list-sink-inputs | grep index | while read line
do
echo "Moving input: ";
echo $line | cut -f2 -d' ';
echo "to sink: $1";
sudo -u linaro PULSE_RUNTIME_PATH=/run/user/1000/pulse pacmd move-sink-input `echo $line | cut -f2 -d' '` $1

done
