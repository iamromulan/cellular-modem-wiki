#!/bin/sh

DEVICE_FILE="/dev/smd7"
TIMEOUT=4

# Function to prepare reading from the device
prepare_device_read() {
    # Clear any existing data and start a new background read process
    cat "$DEVICE_FILE" > /dev/null 2>&1 &
    CAT_PID=$!
    sleep 0.1
    kill -9 $CAT_PID
    wait $CAT_PID 2>/dev/null
    cat "$DEVICE_FILE" > /tmp/device_output &
    CAT_PID=$!
    echo "Background read on $DEVICE_FILE started with PID $CAT_PID"
}

# Function to send AT command to the device
send_at_command() {
    # Ask for the AT command from the user
    printf "Enter AT command: "
    read at_command
    # Send the AT command to the device
    echo -e "${at_command}\r" > "$DEVICE_FILE"
    echo "Command sent to the device. Waiting for response..."
}

# Function to display the device's response
display_response() {
    # Allow some time for the response to be received
    sleep $TIMEOUT
    # Kill the background read process
    kill -9 $CAT_PID 2>/dev/null
    wait $CAT_PID 2>/dev/null
    # Display the response
    RESPONSE=$(< /tmp/device_output)
    if [ -z "$RESPONSE" ]; then
        echo "Error: No response received or response timed out."
    else
        echo "Response from device:"
        echo "$RESPONSE"
    fi
    # Clean up the temporary file
    rm -f /tmp/device_output
}

# Check if the device file exists and is accessible
if [ ! -c "$DEVICE_FILE" ]; then
    echo "Error: The device $DEVICE_FILE does not exist or is not a character special file."
    exit 1
fi

# Run the command reading sequence
prepare_device_read
send_at_command
display_response
