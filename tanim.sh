#!/usr/bin/env bash
set -euo pipefail

# Configuration
FPS=24
END=100  # Reduced for testing
OUTPUT="tanim.mkv"
MUSIC="./assets/music.ogg"
INPUT="./assets/flash.typ"
MODE="software" # Default to software if no argument is provided
PREVIEW=false

function help() {
    echo "Usage: $0 [ARGUMENTS]"
    echo "This script renders a bunch of typst and outputs a video"
    echo "You can use an external video player and set the output file to a"
    echo "stream-friendly format like .mkv to preview while processing."
    echo "You should download the assets via ./download_assets.sh before"
    echo "rendering."
    echo
    echo "Options:"
    echo "  -h --help       Print this message then exit"
    echo "  --nvenc:        Use the NVENC encoder for Nvidia graphics"
    echo "  --vaapi:        Use the VAAPI encoder for Intel graphics"
    echo "  --software:     Use software rendering (default)"
    echo "  --music:        Set the music source"
    echo "  --fps:          Set the FPS of the output"
    echo "  --input:        Set the typst input source"
    echo "  --end:          How many frames to render?"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h)        help; exit 0 ;;
    --help)        help; exit 0 ;;
    --music)    MUSIC="$2"; shift 2 ;;
    --nvenc)    MODE="nvenc"; shift ;;
    --vaapi)    MODE="vaapi"; shift ;;
    --software) MODE="software"; shift ;;
    --fps)      FPS="$2"; shift 2 ;;
    --input)    INPUT="$2"; shift 2 ;;
    --end)      END="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Encoder Logic
case "$MODE" in
  nvenc)
    echo "Using NVENC..."
    # Preset p4 is 'medium', rc vbr + cq is the quality target
    ENC_OPTS="-c:v h264_nvenc -preset p4 -rc vbr -cq 23 -b:v 0"
    V_FILTER="scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,format=yuv420p"
    HW_MAP=""
    ;;
  vaapi)
    echo "Using VAAPI..."
    # Requires uploading frames to GPU memory (hwupload)
    ENC_OPTS="-c:v h264_vaapi -qp 23"
    V_FILTER="scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,format=nv12,hwupload"
    HW_MAP="-vaapi_device /dev/dri/renderD128"
    ;;
  *)
    echo "Using libx264..."
    ENC_OPTS="-c:v libx264 -preset medium -crf 23"
    V_FILTER="scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,format=yuv420p"
    HW_MAP=""
    ;;
esac

# Preload Assets
mkdir -p /dev/shm/tanim
cp -r assets /dev/shm/tanim/

# The Main Pipeline
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
    -i "/dev/shm/tanim/$MUSIC" \
    $HW_MAP \
    -vf "$V_FILTER" \
    -map 0:v:0 -map 1:a:0 \
    -af "loudnorm=I=-16:LRA=7:TP=-1.5" \
    $ENC_OPTS \
    -c:a aac -b:a 192k \
    -shortest \
    "./$OUTPUT"

# Cleanup
rm -r /dev/shm/tanim
