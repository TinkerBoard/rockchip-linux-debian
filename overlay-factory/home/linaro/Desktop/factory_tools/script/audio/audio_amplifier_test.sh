#!/bin/bash
#This is the audio amplifier test tool for tinker board 3 with amplifier.

echo "------------audio_amplifier_test one-shot start------------"

/home/linaro/Desktop/Test_tool/audio_test.sh 0 0 /home/linaro/Desktop/Test_tool/Audio/1hz_Sinewave_1V_mono_1s.wav
sleep 1
freq=$(cat /sys/kernel/pwmcapture_sysfs/get_pwm_freq)
high=$(cat /sys/kernel/pwmcapture_sysfs/get_pwm_high)
low=$(cat /sys/kernel/pwmcapture_sysfs/get_pwm_low)

if [ $freq -gt 300000 ] && [ $high -gt 35 ] && [ $low -gt 35 ]; then
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
