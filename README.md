 ripping-dvd with ffmpeg  cuda nvdec nvenc

Ripping full dvd with all subtitle and all languages


       
       sudo mount /dev/sr0 /dev/dvd
       
       lsdvd /dev/sr0 ### look for longest track on the end of output
       
       mplayer dvd://3    ##  only looking if this is correct
       
       mplayer dvd://3 /dev/sr0 -dumpstream -dumpfile output.vob

from iso file 


       mplayer dvd://3 -dumpstream -dumpfile output.vob ## now you have the dumpstream for the next step to create a mp4 or inthis case mkv
       
or simply       
       
       mpv dvdnav:// --dvd-device=down-by-low.img --stream-dump=output.vob 


mpv       copy to .vob without nr = default movie

       mpv dvdnav:// --dvd-device=down-by-low.img --stream-dump=output.vob

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

       nano ripping.sh

copy and past in     

        #!/bin/bash
        for file in "$1"; do   ffmpeg -fflags +genpts   -ifo_palette default.IFO -y -probesize 2400M -analyzeduration 2410M -hwaccel drm -hwaccel_output_format drm_prime  \
        -canvas_size  720x576  -i "$file"  -ss 00:00:02 -metadata title="$file" \
         -map 0:v -scodec dvdsub   -map 0:s -metadata:s:s:0 language=deu    \
        -c:v h264_v4l2m2m  -b:v 3M  -num_capture_buffers 92   -num_output_buffers 64 -bufsize 5M   -maxrate 5M  -aspect 16:9 \
        -c:a libopus -movflags +faststart    -b:a 128k -map 0:a -metadata:s:a:0 language=en     -f mp4  "${file%.*}.mp4"; done

maybe you heave to set cnvas size to your movie resolution in the script -canvas_size 720x576 to correct the right place

              sudo cp ripping-dvd.sh /usr/local/bin/

and run

       ripping-dvd.sh output.vob

play it

         mpv output.mkv

       
for raspberry



    mkdir dvd
    
than

    sudo mount /dev/sr0 dvd/
and

    mpv dvdnav:// --dvd-device=/dev/sr0 --stream-dump=output.vob


or if it is a iso

    sudo mount /media/storage/dead_man.iso dvd/


dump it

    mpv dvdnav:// --dvd-device=/media/spooky/store/down-by-low.img --stream-dump=/media/spooky/store/output.vob

lokk for GB file the biggest


    ls -lah dvd/VIDEO_TS/


    sudo cp dvd/VIDEO_TS/VTS_02_0.IFO default.IFO

ok

    nano dvdrip.sh copy this in

    #!/bin/bash
  for file in "$1"; do   ffmpeg -ifo_palette default.IFO  -probesize 400M -analyzeduration 410M -hwaccel drm -hwaccel_output_format drm_prime  \
  -canvas_size  720x576  -i "$file"  -ss 00:00:02 -metadata title="$file" \
  -map 0:v -scodec dvdsub   -map 0:s:0 -metadata:s:s:0 language=deu    \
 -c:v h264_v4l2m2m   -b:v 3M  -num_capture_buffers 92   -num_output_buffers 64 -bufsize 5M   -maxrate 5M  -aspect 16:9 \
  -c:a libfdk_aac     -b:a 128k -map 0:a:0 -metadata:s:a:0 language=en     -f mp4  "${file%.*}.mp4"; done

-canvas_size is the size of video input if it is not right the subtitles come not on place


      dvdrip output.vob
