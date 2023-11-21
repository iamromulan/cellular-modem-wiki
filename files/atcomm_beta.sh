#!/bin/sh

DEVICE_FILE="/dev/smd7"
TIMEOUT=4  # Set a timeout for the response

# Function to start listening to the device output in the background
start_listening() {
    # Start 'cat' in the background to read from device
    cat "$DEVICE_FILE" > /tmp/device_readout &
    # Save the background process' PID
    CAT_PID=$!
}

# Function to send the AT command to the device
send_at_command() {
    # Prompt user for the AT command
    echo "Enter AT command (or type 'exit' to quit): "
    read at_command
    # Check if user wants to exit
    if [ "$at_command" = "exit" ]; then
        return 1
    fi
    # Send the AT command to the device
    echo -e "${at_command}\r" > "$DEVICE_FILE"
}

# Function to monitor the device output for a response
wait_for_response() {
    local start_time=$(date +%s)
    local current_time
    local elapsed_time

    echo "Command sent, waiting for response..."
    # Continuously check for 'OK' or 'ERROR' in the output
    while true; do
        # Break the loop if 'OK' or 'ERROR' is found in the output file
        if grep -qe "OK" -e "ERROR" /tmp/device_readout; then
            echo "Response received:"
            cat /tmp/device_readout
            return 0
        fi

        # Check if the timeout has been reached
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ "$elapsed_time" -ge "$TIMEOUT" ]; then
            echo "Error: Response timed out."
            return 1
        fi
        # Check the file every second for new output
        sleep 1
    done
}

# Function to clean up the listening process
cleanup() {
    # Kill the background 'cat' process and clean up temporary files
    kill "$CAT_PID"
    wait "$CAT_PID" 2>/dev/null
    rm -f /tmp/device_readout
}

# Main execution flow
if [ -c "$DEVICE_FILE" ]; then
    while true; do
        start_listening
        send_at_command
        if [ $? -eq 1 ]; then
            cleanup
            break
        fi
        wait_for_response
        cleanup
    done
else
    echo "Error: Device $DEVICE_FILE does not exist or is not a character special file."
fi
