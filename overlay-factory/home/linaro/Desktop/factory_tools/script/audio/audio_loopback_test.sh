#!/bin/bash
#This is the audio loopback tool for tinker board 3 with rk809 codec.
#LOGFILE=/var/log/burnin_test/audio_test.txt
LOGFILE=$1
ONESHOT=$2
pass_cnt=0
fail_cnt=0
i2cget=/usr/sbin/i2cget
i2cset=/usr/sbin/i2cset

log()
{
        echo "$(date +'%Y%m%d_%H.%M.%S') $@" | tee -a $LOGFILE
}

echo "------------audio_loopback_test start------------" > $LOGFILE
echo "Rewrite Mic_In gain to 0dB for adc_loopback"
sudo $i2cset -f -y 0 0x20 0x27 0x00
read_value=`sudo $i2cget -f -y 0 0x20 0x27`
log "0x27_value=$read_value"
sudo $i2cset -f -y 0 0x20 0x29 0x66
read_value=`sudo $i2cget -f -y 0 0x20 0x29`
log "0x29_value=$read_value"
echo "Rewrite Headphone Out volume to -4.125dB for THDN threshold"
sudo $i2cset -f -y 0 0x20 0x31 0x10
read_value=`sudo $i2cget -f -y 0 0x20 0x31`
log "0x31_value=$read_value"
sudo $i2cset -f -y 0 0x20 0x32 0x10
read_value=`sudo $i2cget -f -y 0 0x20 0x32`
log "0x32_value=$read_value"
sleep 1

while [ 1 != 2 ]
do
    #echo "$(date +'%Y%m%d_%H%M%S'), audio_loopback_test play 1kHz" >> $LOGFILE
    /home/linaro/Desktop/Test_tool/audio_test.sh 0 0 /home/linaro/Desktop/Test_tool/Audio/1kHz_Sinewave_mono_30s.wav &
    sleep 1
    #echo "$(date +'%Y%m%d_%H%M%S'), audio_loopback_test record" >> $LOGFILE
    mkdir -p ${LOGFILE%/*}/audio
    FILENAME=${LOGFILE%/*}/audio/record_$(date +'%Y%m%d_%H%M%S').wav
    #echo "audio loopback save record file with timestamp"
    /home/linaro/Desktop/Test_tool/audio_test.sh 1 8 $FILENAME

    #echo "$(date +'%Y%m%d_%H%M%S'), audio_loopback_test kill process" >> $LOGFILE
    pid_of_aplay=$(pidof aplay)
    kill -9 $pid_of_top
    sleep 1
    kill -9 $pid_of_aplay
    sleep 2

    #echo "$(date +'%Y%m%d_%H%M%S'), analyze record file" >> $LOGFILE
    result=$(/home/linaro/Desktop/Test_tool/BurnIn_test/test/audio/asus_audioAnalysis $FILENAME)
    if [ "$result" = "PASS" ]; then
        ((pass_cnt+=1))
        log "audio_loopback_test analyze result: PASS, pass_cnt=$pass_cnt"
        rm -rf $FILENAME
    elif [ "$result" = "FAIL" ]; then
        ((fail_cnt+=1))
	log "audio_loopback_test analyze result: FAIL, fail_cnt=$fail_cnt"
    else
        ((fail_cnt+=1))
        log "audio_loopback_test analyze result: ERROR, fail_cnt=$fail_cnt"
    fi

    #Exit condition
    if [ "$fail_cnt" -ge 6  ]; then
	log "audio_loopback_test pass_cnt=$pass_cnt fail_cnt $fail_cnt"
        exit
    fi

    if [ $# -eq 2 ]; then
        if [ $ONESHOT -eq 1 ]; then
            log "audio_loopback_test pass_cnt=$pass_cnt fail_cnt $fail_cnt"
            exit
        fi
    fi
done
#echo "Oops! memory usage is $usep, audio_lookback_test done."
