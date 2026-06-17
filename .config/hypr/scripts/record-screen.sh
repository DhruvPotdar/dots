#!/usr/bin/env bash

PIDFILE="/tmp/wf-recorder.pid"
OUTPUT_DIR="$(xdg-user-dir VIDEOS)/ScreenRecordings"

mkdir -p "$OUTPUT_DIR"

notify() {
	notify-send "Screen Recording" "$1"
}

is_recording() {
	[[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

start_recording() {
	local geometry="$1"
	local output="$OUTPUT_DIR/recording_$(date '+%Y-%m-%d_%H.%M.%S').mp4"

	if is_recording; then
		notify "Already recording"
		exit 1
	fi

	if [[ -n "$geometry" ]]; then
		wf-recorder -g "$geometry" -f "$output" &
	else
		wf-recorder -f "$output" &
	fi

	echo $! >"$PIDFILE"
	notify "Recording to $(basename "$output")"
}

stop_recording() {
	if ! is_recording; then
		rm -f "$PIDFILE"
		notify "No recording in progress"
		exit 1
	fi

	kill -INT "$(cat "$PIDFILE")"
	wait "$(cat "$PIDFILE")" 2>/dev/null
	rm -f "$PIDFILE"
	notify "Recording saved to $OUTPUT_DIR"
}

case "$1" in
full)
	start_recording
	;;
region)
	geometry=$(slurp) || exit 0
	[[ -z "$geometry" ]] && exit 0
	start_recording "$geometry"
	;;
stop)
	stop_recording
	;;
*)
	echo "Usage: $0 {full|region|stop}"
	exit 1
	;;
esac
