#!/bin/bash
# Nutzung: ./ripping_nvenc_51.sh dein_video.vob

for file in "$1"; do
  ffmpeg -hwaccel nvdec -hwaccel_output_format nv12 \
    -probesize 1200M -analyzeduration 1210M \
    -ifo_palette default.IFO -canvas_size 720x576 \
    -i "$file" -ss 00:00:02 \
    -map 0:v -c:v hevc_nvenc -profile:v main10 -preset p5 -b:v 3M -maxrate 5M -aspect 16:9 \
    -map 0:a -c:a ac3 -b:a 640k \
    -map 0:s -c:s dvdsub \
    -metadata title="$file" \
    -f matroska "${file%.*}_51.mkv"
done
