#!/bin/bash
# Nutzung: ./ripping_nvenc-mkv.sh dein_video.vob

for file in "$1"; do
  ffmpeg -hwaccel nvdec -hwaccel_output_format nv12 \
    -probesize 1200M -analyzeduration 1210M \
    -ifo_palette default.IFO -canvas_size 720x576 \
    -i "$file" -ss 00:00:02 \
    -map 0:v -c:v hevc_nvenc -profile:v main10 -level 5.2 -preset p5 -tune hq \
    -b:v 3M -maxrate 5M -qmin 0 -g 250 -rc-lookahead 20 -aspect 16:9 -r 25 \
    -map 0:a -c:a libfdk_aac -b:a 128k \
    -map 0:s -c:s dvdsub \
    -metadata title="$file" \
    -f matroska "${file%.*}.mkv"
done
