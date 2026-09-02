#!/bin/bash
if pidof hypridle > /dev/null; then
    echo '{"text": "󰒲 ", "class": "deactivated", "tooltip": "Idle inhibitor is inactive (Normal sleep)"}'
else
    echo '{"text": " ", "class": "activated", "tooltip": "Idle inhibitor is active (No sleep)"}'
fi
