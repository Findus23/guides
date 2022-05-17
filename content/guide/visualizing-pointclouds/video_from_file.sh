#!/bin/bash
# inspired by https://gist.github.com/Vestride/278e13915894821e1d6f
# https://trac.ffmpeg.org/wiki/Slideshow
# https://trac.ffmpeg.org/wiki/Encode/H.264
# https://sites.google.com/a/webmproject.org/wiki/ffmpeg/vp9-encoding-guide


# ffmpeg -i $1 -c:v libvpx-vp9 -pass 1 -b:v 3M -threads 8 -speed 4 -tile-columns 6 -frame-parallel 1 -an -pix_fmt yuv420p -f webm -y /dev/null


# ffmpeg -i $1 -c:v libvpx-vp9 -pass 2 -b:v 3M -threads 8 -speed 1 -tile-columns 6 -frame-parallel 1 -auto-alt-ref 1 -lag-in-frames 25 -pix_fmt yuv420p -f webm -y out.webm

ffmpeg -i $1 -vcodec h264 -b:v 1M -strict -2 -pix_fmt yuv420p -preset veryslow -crf 30 -movflags +faststart -y out.mp4
