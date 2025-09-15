#!/usr/bin/env bash
set -euo pipefail

FPS=60
END=600
OUTPUT="par.mkv"

seq 0 $((END)) | parallel -k \
  typst c par.typ \
    --input t={} \
    --ignore-system-fonts \
    --ppi 120 \
    --font-path ./ \
    -f png \
    - | \
  ffmpeg -y -f image2pipe \
    -vcodec png \
    -framerate "$FPS" \
    -i - \
    -i music.mp3 \
    -map 0:v:0 -map 1:a:0 \
    -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,format=yuv420p" \
    -af "loudnorm=I=-16:LRA=7:TP=-1.5" \
    -c:v libx265 -preset medium -crf 23 -threads 0 \
    -c:a aac -b:a 192k \
    -shortest \
    "$OUTPUT"
