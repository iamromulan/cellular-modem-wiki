#!/bin/bash

DEVICE_FILE="/dev/smd7"

# Check if the device file exists
if [ ! -c "$DEVICE_FILE" ]; then
    echo "Error: Device $DEVICE_FILE does not exist or is not a character special file."
    exit 1
fi

# Ask for the AT command from the user
read -p "Enter AT command: " at_command

# Function to display a waiting message and time out after 4 seconds
wait_with_message() {
    local timeout=$1
    local waiting_time=0
    local wait_interval=1

    echo "Waiting for response..."
    while [ $waiting_time -lt $timeout ]; do
        if read -r line <&3; then
            echo "$line"
            return 0
        fi
        sleep $wait_interval
        waiting_time=$((waiting_time + wait_interval))
    done

    echo "Error: Response timed out after ${timeout} seconds."
    return 1
}

# Send the AT command and capture the response
capture_response() {
    # Start 'cat' in the background on the device file, redirected to file descriptor 3
    exec 3< <(cat "$DEVICE_FILE")

    # Send the AT command to the device
    echo -e "$at_command\r" > "$DEVICE_FILE"

    # Call the wait_with_message function with a 4-second timeout
    wait_with_message 4

    # Clean up background process
    exec 3<&-
}

# Run the capture_response function
capture_response
