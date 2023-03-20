#!/bin/bash
#This is the audio loopback tool for tinker board 3 with rk809 codec.
LOGFILE=/var/log/burnin_test/audio_test.txt
echo ""
echo "audio loopback start: "
echo "$(date +'%Y%m%d_%H%M%S'), audio loopback start:" > $LOGFILE
#there is no cut command on tinker board 3, remove memory usage policy
#usep=$(df -t ext4 -t vfat | grep "/dev/root" | tail -n +1 | awk '{ print $5 " " $1 }' | cut -d'%' -f1)
#start_time=$(date +'%s')

#while [ $usep -le 90 ]
while [ 1 != 2 ]
do
    #echo  "current memory usage: $usep"
    #now=$(date +'%s')
    #time_elapse=$(($now-$start_time))
    #echo "elapse(sec): "$time_elapse

    echo "$(date +'%Y%m%d_%H%M%S'), audio loopback play 1kHz start" >> $LOGFILE
    /home/linaro/Desktop/factory_tools/script/audio_test.sh 0 0 /home/linaro/Desktop/factory_tools/files/Audio/1kHz_Sinewave_mono_30s.wav &
    echo "$(date +'%Y%m%d_%H%M%S'), audio loopback play 1kHz success" >> $LOGFILE
    pid_of_top="$!"
    sleep 1
    echo "$(date +'%Y%m%d_%H%M%S'), audio loopback record start" >> $LOGFILE
    #if [ $time_elapse -ge 600 ]
    #then
            FILENAME=/var/log/burnin_test/record_$(date +'%Y%m%d_%H%M%S').wav
            #start_time=$now
            #echo "audio loopback save record file with timestamp"
            /home/linaro/Desktop/factory_tools/script/audio_test.sh 1 8 $FILENAME
    #else
            #/home/linaro/Desktop/factory_tools/script/audio_test.sh 1 8
    #fi

    echo "$(date +'%Y%m%d_%H%M%S'), audio loopback record done, kill $pid_of_top start" >> $LOGFILE
    pid_of_aplay=$(pidof aplay)
    kill -9 $pid_of_top
    sleep 1
    kill -9 $pid_of_aplay
    sleep 1
    echo "$(date +'%Y%m%d_%H%M%S'), audio loopback kill done:" >> $LOGFILE
    usep=$(df -t ext4 -t vfat | grep "/dev/root" | tail -n +1 | awk '{ print $5 " " $1 }' | cut -d'%' -f1)
    #echo  "current usep: $usep"
done
echo "Oops! memory usage is $usep, audio_lookback_test done."
