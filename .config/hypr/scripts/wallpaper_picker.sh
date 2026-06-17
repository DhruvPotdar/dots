#!/bin/bash

# Temporary file to store the selected path
tmp_file=$(mktemp)

# Open yazi in kitty to select a wallpaper
# --chooser-file writes the selected file path to the specified file
/home/dhruvpotdar/.local/kitty.app/bin/kitty --class yazi-picker /home/dhruvpotdar/.cargo/bin/yazi --chooser-file "$tmp_file"

# Read the selected file path
selected=$(cat "$tmp_file")

# Cleanup temp file
rm -f "$tmp_file"

# If a file was selected, set it as wallpaper
if [ -n "$selected" ]; then
    swww img "$selected" --transition-type fade --transition-fps 60

    # Save selection for next boot
    echo "$selected" >~/.config/hypr/current_wallpaper
fi
