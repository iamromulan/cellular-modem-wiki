#!/bin/sh

DEVICE_FILE="/dev/smd7"
TIMEOUT=4

# Make sure to clean up /tmp/device_output before we start
rm -f /tmp/device_output

# Function to send AT command to the device and read the response
send_at_command() {
    # Flush any existing content in the device buffer
    cat "$DEVICE_FILE" > /dev/null 2>&1 &
    CAT_PID=$!
    sleep 0.1
    kill -9 $CAT_PID
    wait $CAT_PID 2>/dev/null

    # Prompt user for the AT command
    echo "Enter AT command: "
    read at_command

    # Send the AT command to the device
    echo -e "${at_command}\r" > "$DEVICE_FILE"

    # Wait a moment to let the device start responding
    sleep 0.5

    # Use 'timeout' to read the response for a specified time and output to a file
    timeout $TIMEOUT cat "$DEVICE_FILE" > /tmp/device_output &

    TIMEOUT_PID=$!
    echo "Waiting for response (PID: $TIMEOUT_PID)..."

    # Wait for timeout to finish
    wait $TIMEOUT_PID

    # Check if timeout process exited normally or was killed
    if [ $? -eq 0 ]; then
        echo "Response received within the timeout period:"
        cat /tmp/device_output
    else
        echo "Error: No response received or response timed out."
    fi

    # Clean up
    rm -f /tmp/device_output
}

send_at_command
