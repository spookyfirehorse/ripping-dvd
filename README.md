 DVD Ripping Guide: High-Speed mit FFmpeg & Hardware-Beschleunigung
Diese Anleitung beschreibt, wie du eine DVD inklusive aller Tonspuren und Untertitel extrahierst und mittels NVENC (Nvidia) oder V4L2 (Raspberry Pi) hocheffizient umwandelst.
Schritt 1: Den Hauptfilm identifizieren & extrahieren
Zuerst finden wir den längsten Track (den Hauptfilm) und dumpen ihn in eine .vob-Datei.
Track-Länge prüfen: lsdvd /dev/sr0 (Suche nach dem längsten Track).
Stream extrahieren:
bash
# Via mpv (empfohlen)
mpv dvdnav:// --dvd-device=/dev/sr0 --cache=no --stream-dump=output.vob
Verwende Code mit Vorsicht.

Schritt 2: Untertitel-Farben sichern (.IFO)
Damit die Untertitel im MKV/MP4 korrekt angezeigt werden, benötigen wir die Farbpalette aus der zugehörigen .IFO-Datei.
Dateien auflisten: ls -lah /dev/sr0/VIDEO_TS/
Identifizieren: Suche die .IFO-Datei, die die gleiche Nummer wie die großen 1GB VOB-Dateien hat (z. B. VTS_07_0.IFO).
Kopieren:
bash
cp /media/dvd/VIDEO_TS/VTS_07_0.IFO default.IFO
Verwende Code mit Vorsicht.

Schritt 3: Encoding-Skripte
Option A: NVIDIA GPU (CUDA/NVENC)
Ideal für PC-Nutzer mit NVIDIA-Grafikkarte. Nutzt hevc_nvenc für 10-Bit HEVC.
ripping_nvenc.sh
bash
#!/bin/bash
# Nutzung: ./ripping_nvenc.sh output.vob
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
Verwende Code mit Vorsicht.

Option B: Raspberry Pi (V4L2/DRM)
Optimiert für den Broadcom-Chip des Raspberry Pi.
ripping_rpi.sh
bash
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
