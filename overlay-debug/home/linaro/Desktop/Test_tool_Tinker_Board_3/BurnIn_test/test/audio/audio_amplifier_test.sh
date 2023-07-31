#!/bin/bash
#This is the audio amplifier test tool for tinker board 3 with amplifier.
LOGFILE=$1
pass_cnt=0
fail_cnt=0

if [ ! -z "$2" ]; then
        freq_lower=$2
else
        freq_lower=250000
fi
if [ ! -z "$3" ]; then
        freq_upper=$3
else
        freq_upper=350000
fi
if [ ! -z "$4" ]; then
        points_lower=$4
else
        points_lower=30
fi
if [ ! -z "$5" ]; then
        points_upper=$5
else
        points_upper=50
fi

log()
{
        echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $LOGFILE
}

echo "------------audio_amplifier_test start------------" > $LOGFILE

while [ 1 != 2 ]
do
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
        ((pass_cnt+=1))
        log "audio_amplifier_test analyze result: PASS, pass_cnt=$pass_cnt"
        rm -rf $FILENAME
    elif [ "$result" = "FAIL" ]; then
        ((fail_cnt+=1))
	log "audio_amplifier_test analyze result: FAIL, fail_cnt=$fail_cnt"
    else
        ((fail_cnt+=1))
        log "audio_amplifier_test analyze result: ERROR, fail_cnt=$fail_cnt"
    fi

    #Exit condition
    if [ "$fail_cnt" -ge 6  ]; then
	log "audio_amplifier_test pass_cnt=$pass_cnt fail_cnt $fail_cnt"
        exit
    fi
done
