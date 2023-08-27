#!/bin/bash

### Right click menu with rofi
# options = "Option 1\nOption 1\n...etc"
link=$(wl-paste -n)
options="Download\nPlay"

# Show options with rofi
selected_option=$(echo -e "$options" | wofi --show dmenu --prompt "$link")


if [[ $link == http*  ]]; then
# Check the option and run it
case "$selected_option" in
     "Download")
         ytdlppath="$HOME/Downloads/yt-dlp"
	echo "option yt"
         yt-dlp -f "bestvideo[height<=1440]+bestaudio/best" -P "$ytdlppath" -q --progress -N 200 "$link"
         ;;
     "Play")
	echo "option mpv"
         mpv "$link"
         ;;
     *)
         ;;
esac
fi
