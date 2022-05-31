#!/bin/bash
# inspired by https://gist.github.com/Vestride/278e13915894821e1d6f
# https://trac.ffmpeg.org/wiki/Slideshow
# https://trac.ffmpeg.org/wiki/Encode/H.264
# https://sites.google.com/a/webmproject.org/wiki/ffmpeg/vp9-encoding-guide


ffmpeg -framerate 30 -i img.%04d.png -c:v libvpx-vp9 -pass 1 -b:v 25M  -speed 4 -tile-columns 6 -frame-parallel 1 -row-mt 1 -an -pix_fmt yuv420p -f webm -y /dev/null


ffmpeg -framerate 30 -i img.%04d.png -c:v libvpx-vp9 -pass 2 -b:v 25M  -speed 1 -tile-columns 6 -frame-parallel 1 -row-mt 1 -auto-alt-ref 1 -lag-in-frames 25 -pix_fmt yuv420p -f webm -y out.webm

ffmpeg -framerate 30 -i img.%04d.png -vcodec h264 -b:v 1M -strict -2 -pix_fmt yuv420p -preset veryslow -crf 20 -movflags +faststart -y out.mp4
