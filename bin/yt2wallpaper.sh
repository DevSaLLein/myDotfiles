#!/bin/bash

OUTDIR="$HOME/Videos/wallpapers"
mkdir -p "$OUTDIR"

if [ "$#" -lt 1 ]; then
  echo "Uso: $0 <link1> [link2] [link3] ..."
  exit 1
fi

for LINK in "$@"; do
  TITLE=$(yt-dlp --get-title "$LINK" | head -n 1 | tr ' ' '_' | tr -dc 'A-Za-z0-9_-')
  TMPFILE="$(mktemp --suffix=.mp4)"
  OUTFINAL="$OUTDIR/${TITLE}_wallpaper.mp4"

  echo "Baixando: $LINK"
  yt-dlp -f "bestvideo[height<=1080][fps<=60]+bestaudio/best[height<=1080]" -S "fps,ext:mp4" --merge-output-format mp4 "$LINK" -o "$TMPFILE"

  echo "Cortando e compactando: $TITLE"
  ffmpeg -y -i "$TMPFILE" -t 30 -vf "scale=1280:720,fps=30" -b:v 2M -c:a copy "$OUTFINAL"

  rm -f "$TMPFILE"

  echo "Pronto! Wallpaper salvo em $OUTFINAL"
done