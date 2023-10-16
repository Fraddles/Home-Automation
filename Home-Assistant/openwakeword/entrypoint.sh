#!/bin/bash

args=(
        # Enter your Home Assistant host and long-lived access token here
        --host="home-assistant.fraddles.com"
        --token="<put your token here>"

        # If needed, enter specific speaker / microphone ALSA devices here
        --mic-device="plughw:CARD=P20,DEV=0"
        --snd-device="plughw:CARD=P20,DEV=0"

        --awake-sound="/venv/sounds/awake.wav"
        --done-sound="/venv/sounds/done.wav" 

        --volume=1.0
        --volume-multiplier=1.5
        --vad silero

        --protocol https

#       --debug
#       --debug-recording-dir /recordings
)

/venv/bin/python3 -m homeassistant_satellite "${args[@]}"
