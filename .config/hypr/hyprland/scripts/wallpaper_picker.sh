#!/bin/bash

# Open file picker using zenity
selected=$(zenity --file-selection --title="Select Wallpaper" --file-filter="Images | *.jpg *.jpeg *.png *.webp")

# If a file was selected, set it as wallpaper
if [ -n "$selected" ]; then
    swww img "$selected" --transition-type fade --transition-fps 60

    # Save selection for next boot
    echo "$selected" >~/.config/hypr/current_wallpaper
fi
