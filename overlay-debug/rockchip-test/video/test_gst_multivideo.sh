#!/bin/bash

export PREFERED_VIDEOSINK=xvimagesink
export QT_GSTREAMER_WIDGET_VIDEOSINK=${PREFERED_VIDEOSINK}
export QT_GSTREAMER_WINDOW_VIDEOSINK=${PREFERED_VIDEOSINK}

echo performance | tee $(find /sys/ -name *governor) /dev/null || true
ln -sf /usr/lib/aarch64-linux-gnu/pulseaudio/libpulsecommon-14.2.so /usr/lib/libpulsecommon-14.2.so
./multivideoplayer -platform xcb
