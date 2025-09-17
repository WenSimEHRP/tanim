#!/usr/bin/env bash
set -euo pipefail

FPS=24
END=0xFFFF
OUTPUT="tanim.mkv"
INPUT="flash.typ"

# preload all assets from `assets` into RAM
mkdir -p /dev/shm/tanim
cp -r assets/* /dev/shm/tanim/

seq 0 $((END)) | parallel -k \
  typst c "/dev/shm/tanim/$INPUT" \
    --input t={} \
    --ignore-system-fonts \
    --ppi 120 \
    --font-path /dev/shm/tanim/ \
    -f png \
    - | \
  ffmpeg -y -f image2pipe \
    -vcodec png \
    -framerate "$FPS" \
    -i - \
    -i /dev/shm/tanim/music.mp3 \
    -map 0:v:0 -map 1:a:0 \
    -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,format=yuv420p" \
    -af "loudnorm=I=-16:LRA=7:TP=-1.5" \
    -c:v h264_nvenc -preset medium -crf 23 -threads 0 \
    -c:a aac -b:a 192k \
    -shortest \
    "/dev/shm/$OUTPUT"

# copy final output to current directory
cp "/dev/shm/$OUTPUT" ./

# clean up
rm -rf /dev/shm/tanim
rm -f "/dev/shm/$OUTPUT"
