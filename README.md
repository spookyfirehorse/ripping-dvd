 ripping-dvd with ffmpeg

Ripping full dvd with all subtitle and all languages


       
       sudo mount /dev/sr0 /dev/dvd
       lsdvd /dev/sr0 ### look for longest track on the end of output
       mplayer dvd://3    ##  only looking if this is correct
       mplayer dvd://3 -dumpstream -dumpfile output.vob ## now you have the dumpstream for the next step to create a mp4 or inthis case mkv
       mpv dvdnav:// --dvd-device=/media/spooky/store/down-by-low.img --stream-dump=/media/spooky/store/output.vob 


mpv       copy to .vob without nr = default movie

       mpv dvdnav:// --dvd-device=/media/spooky/store/down-by-low.img --stream-dump=/media/spooky/store/output.vob

now you heave the vob file

now you neeed the .IFO file for your movie for the subtitle

so you heave to copy the file in your home directory named default.IFO

               ls -lah dvd/VIDEO_TS/

-r--r--r-- 1 nobody nogroup  44K  7. Feb 2036  VTS_07_0.IFO

-r--r--r-- 1 nobody nogroup 9,7M  7. Feb 2036  VTS_07_0.VOB

-r--r--r-- 1 nobody nogroup 1,0G  7. Feb 2036  VTS_07_1.VOB

-r--r--r-- 1 nobody nogroup 1,0G  7. Feb 2036  VTS_07_2.VOB

-r--r--r-- 1 nobody nogroup 1,0G  7. Feb 2036  VTS_07_3.VOB

-r--r--r-- 1 nobody nogroup 1,0G  7. Feb 2036  VTS_07_4.VOB

 -r--r--r-- 1 nobody nogroup 1,0G  7. Feb 2036  VTS_07_5.VOB
 
 -r--r--r-- 1 nobody nogroup 251M  7. Feb 2036  VTS_07_6.VOB


and looking for 1 gb files


the IFO file before is the right one 



in this case


       sudo cp /dev/dvd/VTS_07_0.IFO default.IFO  


so now the finsh

       nano example.sh

copy and past in     

        #!/bin/bash
       for file in "$1"; do   ffmpeg   -hwaccel cuda -probesize 1200M -analyzeduration 1210M   -hwaccel_output_format nv12 -ifo_palette default.IFO    \
        -canvas_size 720x576  -i "$file"  -ss 00:00:02     -metadata title="$file"  -map 0:v -scodec dvdsub  \
         -map 0:s     -c:v hevc_nvenc -profile:v main10  -level 5.2 -preset p5 -tune hq -b:v 3M -maxrate 5M   -qmin 0 -g 250 -rc-lookahead 20 -aspect 16:9   \
         -c:a libfdk_aac  -b:a 128k  -map 0:a  -f matroska  "${file%.*}.mkv"; done

maybe you heave to set cnvas size to your movie resolution in the script -canvas_size 720x576 to correct the right place

              sudo cp ripping-dvd.sh /usr/local/bin/

and run

       ripping-dvd.sh output.vob

play it

         mpv output.mkv

       
android

       ffmpeg   -hwaccel cuda -hwaccel_output_format nv12   -fflags +genpts+nobuffer+discardcorrupt   -hide_banner -rtsp_transport tcp   -i rtsp://127.0.0.1:8080/h264_pcm.sdp -c:v h264_nvenc -b:v 1M  -preset p1 -tune ll       -c:a libopus  -b:a 64k  -application lowdelay  -ar 48000  -f rtsp -rtsp_transport tcp  rtsp://localhost:8559/mystream
