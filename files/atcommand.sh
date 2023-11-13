#!/bin/sh

DEVICE_FILE="/dev/smd7"
TIMEOUT=4

# Ensure the device file exists
if [ ! -c "$DEVICE_FILE" ]; then
    echo "Error: Device $DEVICE_FILE does not exist or is not a character special file."
    exit 1
fi

# Function to send the AT command to the device
send_at_command() {
    # Clear device buffer by reading any pending data
    cat "$DEVICE_FILE" > /dev/null 2>&1 & 
    CAT_PID=$!
    sleep 0.1
    kill -9 $CAT_PID
    wait $CAT_PID 2>/dev/null

    # Send the AT command to the device
    echo -e "$1\r" > "$DEVICE_FILE"

    # Read the response
    RESPONSE=""
    { 
        # Give device a moment to start responding
        sleep 0.2
        # Capture the response for a duration of TIMEOUT
        RESPONSE=$(timeout $TIMEOUT cat "$DEVICE_FILE")
    }

    if [ -z "$RESPONSE" ]; then
        echo "Error: Response timed out or no data received."
    else
        echo "Response from device:"
        echo "$RESPONSE"
    fi
}

# Main execution flow
printf "Enter AT command: "
read at_command
send_at_command "$at_command"
