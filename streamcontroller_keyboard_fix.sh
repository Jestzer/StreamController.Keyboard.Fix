#!/bin/bash

# Maximum number of attempts before quitting.
MAX_ATTEMPTS=3
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do

    # Get the device IDs for "stream-controller-os-plugin" under Virtual core keyboard section.
    # Finding it in the wrong section can screw up other things, like settings your physical keyboard layout to US.
    S_DEVICE_IDS=$(xinput -list | grep -A 10 'Virtual core keyboard' | grep 'stream-controller-os-plugin' | sed -n 's/.*id=\([0-9]\+\).*/\1/p')
    
    echo "Found Stream Deck device IDs: $S_DEVICE_IDS"

    # Check if any device IDs are found.
    if [ -n "$S_DEVICE_IDS" ]; then
        for S_DEVICE_ID in $S_DEVICE_IDS; do
            # Try to set the keyboard layout to US for each device ID.
            if setxkbmap -device $S_DEVICE_ID -layout us; then
                echo "Stream Deck keyboard layout set to US for device ID $S_DEVICE_ID."
                exit 0
            else
                echo "Failed to set Stream Deck keyboard layout for device ID $S_DEVICE_ID. Trying next ID if available."
            fi
        done
    else
        echo "stream-controller-os-plugin device not found. Attempt $ATTEMPT of $MAX_ATTEMPTS."
    fi

    ATTEMPT=$((ATTEMPT + 1))
    sleep 5
done

echo "Failed to set keyboard layout for any stream-controller-os-plugin device after $MAX_ATTEMPTS attempts."
exit 1