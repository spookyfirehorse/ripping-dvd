#!/bin/bash
# Nutzung: ./ripping_rpi-mkv.sh dein_video.vob

for file in "$1"; do
  ffmpeg -hwaccel drm -hwaccel_output_format drm_prime \
    -probesize 400M -analyzeduration 410M \
    -ifo_palette default.IFO -canvas_size 720x576 \
    -i "$file" -ss 00:00:02 \
    -map 0:v -c:v h264_v4l2m2m -b:v 3M -num_capture_buffers 92 -num_output_buffers 64 \
    -bufsize 5M -maxrate 5M -aspect 16:9 \
    -map 0:a -c:a libfdk_aac -b:a 128k \
    -map 0:s -c:s dvdsub \
    -metadata title="$file" \
    -f matroska "${file%.*}.mkv"
done
