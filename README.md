The provided text outlines a process for high-speed DVD ripping using FFmpeg with hardware acceleration, specifically leveraging NVENC for Nvidia GPUs or V4L2 for Raspberry Pi [1.2]. The guide details steps to identify and extract the main movie track, secure subtitle color palettes from .IFO files, and provides bash scripts for encoding the content into MKV format [1.2]. The guide also includes instructions for script installation and execution, alongside important notes regarding canvas size, language tags, and the necessity of the .IFO file for correct subtitle display [1.2]. More information is available on the GitHub repository.



# Via mpv (empfohlen)
```bash
mpv dvdnav:// --dvd-device=/dev/sr0 --cache=no --stream-dump=output.vob
```


```bash
cp /media/dvd/VIDEO_TS/VTS_07_0.IFO default.IFO
```
Verwende Code mit Vorsicht.

Schritt 3: Encoding-Skripte
Option A: NVIDIA GPU (CUDA/NVENC)
Ideal für PC-Nutzer mit NVIDIA-Grafikkarte. Nutzt hevc_nvenc für 10-Bit HEVC.
ripping_nvenc.sh

#!/bin/bash
# Nutzung: ./ripping_nvenc.sh output.vob
```bash
for file in "$1"; do
  ffmpeg -hwaccel nvdec -hwaccel_output_format nv12 \
  -probesize 1200M -analyzeduration 1210M \
  -ifo_palette default.IFO -canvas_size 720x576 \
  -i "$file" -ss 00:00:02 \
  -map 0:v -c:v hevc_nvenc -profile:v main10 -preset p5 -tune hq -b:v 3M -maxrate 5M -aspect 16:9 \
  -map 0:a -c:a libfdk_aac -b:a 128k \
  -map 0:s -scodec dvdsub \
  -metadata title="$file" -f matroska "${file%.*}_main10.mkv"
done
```
Verwende Code mit Vorsicht.

Option B: Raspberry Pi (V4L2/DRM)
Optimiert für den Broadcom-Chip des Raspberry Pi.
ripping_rpi.sh

```bash
#!/bin/bash
# Nutzung: ./ripping_rpi.sh output.vob
for file in "$1"; do
  ffmpeg -hwaccel drm -hwaccel_output_format drm_prime \
  -probesize 400M -analyzeduration 410M \
  -ifo_palette default.IFO -canvas_size 720x576 \
  -i "$file" -ss 00:00:02 \
  -map 0:v -c:v h264_v4l2m2m -b:v 3M -num_capture_buffers 92 -aspect 16:9 \
  -map 0:a -c:a libfdk_aac -b:a 128k \
  -map 0:s -scodec dvdsub \
  -f mp4 "${file%.*}.mp4"
done
```

```bash
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
```


chmod +x ripping_nvenc_51.sh

```bash
cat << 'EOF' > ripping_rpi.sh
#!/bin/bash
# Nutzung: ./ripping_rpi.sh dein_video.vob

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
EOF
```

chmod +x ripping_rpi.sh



Verwende Code mit Vorsicht.

Schritt 4: Installation & Ausführung
Rechte vergeben:
chmod +x ripping_nvenc.sh
Global verfügbar machen (optional):
sudo cp ripping_nvenc.sh /usr/local/bin/ripping-dvd
Starten:
ripping-dvd output.vob
Wichtige Hinweise:
Canvas Size: Falls die Untertitel verschoben sind, prüfe die Auflösung deiner Quelle mit ffprobe und passe -canvas_size (z. B. 720x480 für NTSC) an.
Sprach-Tags: Im Skript sind language=deu und language=en als Metadaten gesetzt. Diese kannst du je nach DVD im FFmpeg Metadata Guide anpassen.
