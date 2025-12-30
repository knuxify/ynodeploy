#!/bin/sh

# convert.sh - convert mp3, wav, ogg and midi files to opus

find "$*" -type f \( -name "*.wav" -o -name "*.mp3" -o -name "*.ogg" \) \
	      -exec sh -c 'ffmpeg -y -i "$1" -c:a libopus -b:a 96K "${1%.*}.opus" && rm -f "$1"' _ {} \;

find "$*" -type f \( -name "*.mid" -o -name "*.midi" \) \
	      -exec sh -c 'fluidsynth -r 44100 -a pipewire -T raw -F temp /opt/sf/MSGS_Fixed.sf2 "$1" && ffmpeg -y -f s32le -i temp -c:a libopus -b:a 96K "${1%.*}.opus" && rm -f temp && rm -f "$1"' _ {} \;
