#!/bin/bash
#This is the factory test tool for tinker board 3.

REC_FILENAME_A=/var/log/burnin_test/record_A.wav
REC_FILENAME_B=/var/log/burnin_test/record_B.wav
REC_FILENAME=record.wav
#LOGFILE=/var/log/burnin_test/audio_test.txt

function audio_test_usage() {
    cat <<USAGE_MESSAGE
usage: ./audio_test.sh [OPTION] ...
    OPTION:
        0 - playback [SINK] [FILE]
        1 - record [RECORD_TIME] [RECORD_FILE(optional)]
        2 - record_and_playback [SINK] [RECORD_TIME]
        3 - playback on repeat [SINK] [FILE]
        4 - audio loopback test
    SINK:
        0 - Headphone output
        1 - HDMI output
    FILE:
        Select a file you want play
    RECORD_TIME:
        Recording time in seconds
    RECORD_FILE:
        Select a file and path wich you want to record
USAGE_MESSAGE
}

function audio_test_record() {
    if [ "$#" -lt 1 ]
    then
        echo "audio_test_record(): Too few arguments!!" >&2
        audio_test_usage;
        return 1;
    fi

    REC_TIME="$1"

    if [ "$#" -lt 2 ]
    then
        if [ -f "$REC_FILENAME_A" ]
        then
            echo "Now record file is $REC_FILENAME_B"
            #echo "$(date +'%Y%m%d_%H%M%S'), Record B start:" >> $LOGFILE
            arecord -Dhw:$rk809_card_num -f S16_LE -r 48000 -c 2 -d $REC_TIME $REC_FILENAME_B
            #echo "$(date +'%Y%m%d_%H%M%S'), Record B done, start rm record_A.wav:" >> $LOGFILE
            rm -rf $REC_FILENAME_A
            #echo "$(date +'%Y%m%d_%H%M%S'), remove record_A.wav done:" >> $LOGFILE
        else
            echo "Now record file is $REC_FILENAME_A"
            #echo "$(date +'%Y%m%d_%H%M%S'), Record A start:" >> $LOGFILE
            arecord -Dhw:$rk809_card_num -f S16_LE -r 48000 -c 2 -d $REC_TIME $REC_FILENAME_A
            #echo "$(date +'%Y%m%d_%H%M%S'), Record B done, start rm record_A.wav:" >> $LOGFILE
            rm -rf $REC_FILENAME_B
            #echo "$(date +'%Y%m%d_%H%M%S'), remove record_B.wav done:" >> $LOGFILE
        fi
    else
        REC_FILENAME="$2"
        echo "Now record file is $REC_FILENAME"
        #echo "$(date +'%Y%m%d_%H%M%S'), Record start:" >> $LOGFILE
        arecord -Dhw:$rk809_card_num -f S16_LE -r 48000 -c 2 -d $REC_TIME $REC_FILENAME
       # echo "$(date +'%Y%m%d_%H%M%S'), Record done" >> $LOGFILE
    fi

    if [[ $? -ne 0 ]]
    then
        return 1
    fi

    return $?
}

function audio_test_playback() {
    DEVICE="$1"
    FILENAME="$2"
    case "$DEVICE" in
        '0') # Headphone Output
            #echo "$(date +'%Y%m%d_%H%M%S'), aplay start:" >> $LOGFILE
            aplay -Dplughw:$rk809_card_num $FILENAME
            #echo "$(date +'%Y%m%d_%H%M%S'), aplay done:" >> $LOGFILE
            if [[ $? -ne 0 ]]
            then
                return 1
            fi
            return $?
            ;;
        '1') # HDMI Output
            aplay -Dplughw:$hdmi_card_num $FILENAME
            if [[ $? -ne 0 ]]
            then
                return 1
            fi
            return $?
            ;;
        *)
            echo "Unknown sink '$DEVICE'" >&2
            audio_test_usage;
            return 1;
            ;;
    esac
}

function audio_test_playback_repeat() {
    DEVICE="$1"
    FILENAME="$2"
    case "$DEVICE" in
        '0') # Headphone Output
            while [ $? -eq 0 ] ; do
                aplay -Dplughw:$rk809_card_num $FILENAME
            done
            if [[ $? -ne 0 ]]
            then
                return 1
            fi
            return $?
            ;;
        '1') # Line Out
            while [ $? -eq 0 ] ; do
                aplay -Dplughw:$hdmi_card_num $FILENAME
            done
            if [[ $? -ne 0 ]]
            then
                return 1
            fi
            return $?
            ;;
        *)
            echo "Unknown sink '$DEVICE'" >&2
            audio_test_usage;
            return 1;
            ;;
    esac
}

function audio_test_loopback() {
    echo "Start audio loopback ..."
    while [ $? -eq 0 ] ; do
        arecord -Dhw:$rk809_card_num -f S16_LE -r 48000 -c 2 | aplay -Dplughw:$rk809_card_num -f S16_LE -r 48000 -c 1
    done
    if [[ $? -ne 0 ]]
    then
        return 1
    fi

    return $?
}

function audio_test_rec_n_play() {
    if [ "$#" -lt 2 ]
    then
        echo "Too few arguments!!" >&2
        audio_test_usage;
        return 1;
    fi

    REC_TIME="$2"

    echo "Now record file is $REC_FILENAME"
    arecord -Dhw:$rk809_card_num -f S16_LE -r 48000 -c 2 -d $REC_TIME $REC_FILENAME

    if [[ $? -ne 0 ]]
    then
        return 1
    fi

    audio_test_playback "$1" "$REC_FILENAME" || return 1
}

function audio_test_main() {
    #echo "audio_test : "

    if [ $# -le 0 ]
    then
        echo "audio_test_main(): Too few arguments!!" >&2
        audio_test_usage;
        return 1
    fi

    #echo ==================== "Current Sound Card(s)" ====================
    #cat /proc/asound/cards
    #echo ===============================================================
    out=$(cat /proc/asound/cards | grep rockchiphdmi)
    hdmi_card_num=$(echo $out | cut -d" " -f 1)
    #echo "rockchiphdmi, card number = "$hdmi_card_num
    out=$(cat /proc/asound/cards | grep rockchiprk809)
    rk809_card_num=$(echo $out | cut -d" " -f 1)
    #echo "rockchiprk809 card, card number = "$rk809_card_num

    ACTION="$1"
    shift

    case "$ACTION" in
        '0') # Playback
            audio_test_playback "$@" || return 1
            ;;
        '1') # Record
            audio_test_record "$@" || return 1
            ;;
        '2') # Record & Playback
            audio_test_rec_n_play "$@" || return 1
            ;;
        '3') # Playback on repeat
            audio_test_playback_repeat "$@" || return 1
            ;;
        '4') # Audio loopback
            audio_test_loopback "$@" || return 1
            ;;
        *)
            audio_test_usage;
            return 1
            ;;
    esac
}

audio_test_main "$@"
#if [[ $? -eq 0 ]]
#then
    #echo "PASS";
#else
    #echo "FAIL";
#fi
