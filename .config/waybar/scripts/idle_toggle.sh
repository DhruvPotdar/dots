#!/bin/bash
if pidof hypridle > /dev/null; then
    killall hypridle
    notify-send -a "Waybar" -i "coffee" -u low "Idle Inhibitor" "No Sleep Enabled ☕\n(Your laptop will stay awake)"
else
    hypridle &
    notify-send -a "Waybar" -i "sleep" -u low "Idle Inhibitor" "Normal Sleep Enabled 󰒲\n(Your laptop will sleep normally)"
fi
