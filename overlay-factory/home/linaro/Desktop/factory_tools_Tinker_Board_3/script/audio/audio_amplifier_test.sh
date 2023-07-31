#!/bin/bash
#This is the audio amplifier test tool for tinker board 3 with amplifier.

if [ ! -z "$1" ]; then
        freq_lower=$1
else
        freq_lower=250000
fi
if [ ! -z "$2" ]; then
        freq_upper=$2
else
        freq_upper=350000
fi
if [ ! -z "$3" ]; then
        points_lower=$3
else
        points_lower=30
fi
if [ ! -z "$4" ]; then
        points_upper=$4
else
        points_upper=50
fi

echo "------------audio_amplifier_test one-shot start------------"

sudo su -c "echo 0 > /sys/kernel/pwmcapture_sysfs/pwm_freq"
/home/linaro/Desktop/Test_tool/audio_test.sh 0 0 /home/linaro/Desktop/Test_tool/Audio/1hz_Sinewave_1V_mono_1s.wav
sleep 1
freq=$(cat /sys/kernel/pwmcapture_sysfs/pwm_freq)
high=$(cat /sys/kernel/pwmcapture_sysfs/get_pwm_high)
low=$(cat /sys/kernel/pwmcapture_sysfs/get_pwm_low)
echo "pwm_freq:" $freq ", pwm_high:" $high ", pwm_low" $low

if [ $freq -gt $freq_lower ] && [ $freq -lt $freq_upper ] && [ $high -gt $points_lower ] && [ $high -lt $points_upper ] && [ $low -gt $points_lower ] && [ $low -lt $points_upper ]; then
    result=PASS
else
    result=FAIL
fi

if [ "$result" = "PASS" ]; then
    echo "PASS"
elif [ "$result" = "FAIL" ]; then
    echo "FAIL"
else
    echo "ERROR"
fi
