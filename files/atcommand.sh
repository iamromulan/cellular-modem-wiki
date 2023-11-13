#!/bin/bash

DEVICE_FILE="/dev/smd7"
TIMEOUT=4

# Check if the device file exists
if [ ! -c "$DEVICE_FILE" ]; then
    echo "Error: Device $DEVICE_FILE does not exist or is not a character special file."
    exit 1
fi

# Ask for the AT command from the user
read -p "Enter AT command: " at_command

# Function to start cat in the background, send the AT command, and output the response
function send_at_command {
    # Start 'cat' in the background and redirect output to a temporary file
    cat "$DEVICE_FILE" > /tmp/device_output &
    CAT_PID=$!

    # Wait a little bit to ensure 'cat' is ready
    sleep 0.5

    # Send the AT command to the device
    echo -e "${at_command}\r" > "$DEVICE_FILE"

    # Show a waiting message
    echo "Waiting for response..."

    # Wait for response with a timeout
    {
        sleep "$TIMEOUT" && kill $CAT_PID
    } &

    WAIT_PID=$!

    # Wait for either cat to finish or the timeout
    wait $CAT_PID 2>/dev/null
    EXIT_STATUS=$?

    # Kill the sleep command if it's still running
    kill $WAIT_PID 2>/dev/null

    # Check if 'cat' was successful
    if [ $EXIT_STATUS -eq 0 ]; then
        # 'cat' exited normally, show the output
        cat /tmp/device_output
    else
        # 'cat' failed or was killed, assume timeout
        echo "Error: Response timed out."
    fi

    # Clean up
    rm /tmp/device_output
}

# Run the function
send_at_command
