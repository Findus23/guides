#!/bin/bash
# inspired by https://gist.github.com/Vestride/278e13915894821e1d6f
# https://trac.ffmpeg.org/wiki/Slideshow
# https://trac.ffmpeg.org/wiki/Encode/H.264
# https://sites.google.com/a/webmproject.org/wiki/ffmpeg/vp9-encoding-guide

case "$1" in
  VP9)
    ffmpeg -framerate 30 -i /tmp/images/test_%04d.png -c:v libvpx-vp9 -pass 1 -crf 35 -b:v 15M -deadline good -cpu-used 0 -row-mt 1 -tile-columns 3 -frame-parallel 1 -an -pix_fmt yuv420p -f webm -y /dev/null

    ffmpeg -framerate 30 -i /tmp/images/test_%04d.png -c:v libvpx-vp9 -pass 2 -crf 35 -b:v 15M -deadline good -cpu-used 0  -row-mt 1 -tile-columns 3 -frame-parallel 1 -auto-alt-ref 1 -lag-in-frames 25 -pix_fmt yuv420p -f webm -y -an out.webm
    ;;
  AV1)
    ffmpeg -framerate 30 -i /tmp/images/test_%04d.png -c:v libsvtav1 -pass 1 -crf 35 -b:v 7M -preset 8 -svtav1-params fast-decode=1 -an -pix_fmt yuv420p -f webm -y /dev/null

    ffmpeg -framerate 30 -i /tmp/images/test_%04d.png -c:v libsvtav1 -pass 2 -crf 35 -b:v 7M -preset 8 -svtav1-params fast-decode=1 -pix_fmt yuv420p -f webm -y -an out-av1.webm
    ;;
  MP4)
    ffmpeg -framerate 30 -i /tmp/images/test_%04d.png -vcodec h264 -b:v 15M -strict -2 -pix_fmt yuv420p -preset veryslow -crf 35 -movflags +faststart -y out.mp4
    ;;
  *)
    echo "VP9 or MP4"
esac
