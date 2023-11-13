#!/bin/sh

DEVICE_FILE="/dev/smd7"
TIMEOUT=4  # Set a timeout for the response

# Check if the device file exists and is a character special file
if [ ! -c "$DEVICE_FILE" ]; then
    echo "Error: The device $DEVICE_FILE does not exist or is not a character special file."
    exit 1
fi

# Function to configure device and read output
setup_device_and_read() {
    # Start cat in the background to read from device
    cat "$DEVICE_FILE" > /tmp/device_readout &
    # Record cat's process ID
    CAT_PID=$!
    echo "Listening on $DEVICE_FILE with PID $CAT_PID"
}

# Function to send AT command to the device
send_at_command() {
    # Prompt user for the AT command
    echo "Enter AT command: "
    read at_command
    # Send the AT command to the device
    echo -e "${at_command}\r" > "$DEVICE_FILE"
    echo "Command sent, waiting for response..."
}

# Function to kill the cat process after a timeout and display the output
kill_cat_process_and_show_output() {
    # Sleep for the specified timeout to allow a response
    sleep "$TIMEOUT"
    # Kill the cat process
    kill "$CAT_PID"
    wait "$CAT_PID" 2>/dev/null
    echo "Stopped listening on $DEVICE_FILE. Response is:"
    # Output the captured data
    cat /tmp/device_readout
    # Clean up
    rm /tmp/device_readout
}

# Start the script execution
setup_device_and_read
send_at_command
kill_cat_process_and_show_output
