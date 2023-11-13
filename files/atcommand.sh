#!/bin/sh

DEVICE_FILE="/dev/smd7"
TIMEOUT=4

# Function to send AT command and read response
send_at_command() {
    # Clear any previous output in the device file
    cat "$DEVICE_FILE" > /dev/null 2>&1 & 
    CAT_PID=$!
    sleep 0.2
    kill -9 $CAT_PID
    wait $CAT_PID 2>/dev/null

    # Send the AT command
    printf "$1\r" > "$DEVICE_FILE"
    sleep 0.5  # Wait half a second to ensure the command is sent

    # Start reading the response
    RESPONSE=""
    exec 3<> "$DEVICE_FILE" # Open the device file for reading and writing
    (sleep "$TIMEOUT"; echo) >&3 & # Send a delayed newline to unblock 'read'
    while IFS= read -r line <&3; do
        RESPONSE="${RESPONSE}${line}\n"
        if [ -n "$line" ] && [ "$line" = "OK" ]; then
            break
        fi
    done

    # Output the response
    if [ -z "$RESPONSE" ]; then
        echo "Error: No response received, or response timed out."
    else
        echo "Response from device:"
        echo "$RESPONSE"
    fi
    exec 3<&- # Close the file descriptor
}

# Main logic
if [ ! -c "$DEVICE_FILE" ]; then
    echo "Error: Device $DEVICE_FILE does not exist or is not a character special file."
    exit 1
fi

echo "Enter AT command:"
read at_command
send_at_command "$at_command"
