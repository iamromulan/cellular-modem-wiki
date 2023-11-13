#!/bin/bash

# Path to the device file
DEVICE_FILE="/dev/smd7"

# Check if the device file exists
if [ ! -e "$DEVICE_FILE" ]; then
    echo "Error: Device file $DEVICE_FILE does not exist."
    exit 1
fi

# Function to read the AT command from user input
read_at_command() {
    read -p "Enter AT command: " at_command
    echo -e "$at_command\r"
}

# Function to send the AT command to the device and read the response
send_and_read_response() {
    # Send the AT command to the device file
    read_at_command > "$DEVICE_FILE"

    # Display waiting message
    echo "Waiting for response..."

    # Use 'timeout' to run 'cat' with a 4-second limit
    response=$(timeout 4 cat "$DEVICE_FILE")

    # Check if timeout command timed out
    if [ $? -eq 124 ]; then
        echo "Error: Response timed out."
    else
        # Display the response
        echo "Response from device:"
        echo "$response"
    fi
}

# Execute the send and read function
send_and_read_response
