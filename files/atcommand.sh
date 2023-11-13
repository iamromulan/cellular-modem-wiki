#!/bin/sh

DEVICE_FILE="/dev/smd7"
TIMEOUT=4

# Check if the device file exists and is a character special file
if [ ! -c "$DEVICE_FILE" ]; then
    echo "Error: Device $DEVICE_FILE does not exist or is not a character special file."
    exit 1
fi

# Ask for the AT command from the user
printf "Enter AT command: "
read at_command

# Function to send the AT command to the device and read the response
send_at_command() {
    # Start background process to read the device output
    (cat "$DEVICE_FILE" & sleep "$TIMEOUT" && pkill -P $$ cat) > /tmp/device_response &
    CAT_PID=$!
    sleep 0.1  # Give it a moment to ensure the background process is set up

    # Send the AT command to the device
    printf "${at_command}\r" > "$DEVICE_FILE"

    # Wait for the background process to complete or timeout
    wait $CAT_PID
    sleep 0.1  # Allow time for the output to be flushed to the temp file

    # Output the response
    RESPONSE=$(cat /tmp/device_response)
    if [ -z "$RESPONSE" ]; then
        echo "Error: No response received, or response timed out."
    else
        echo "Response from device:"
        echo "$RESPONSE"
    fi

    # Clean up
    rm -f /tmp/device_response
}

send_at_command
