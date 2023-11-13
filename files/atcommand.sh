#!/bin/sh

DEVICE_FILE="/dev/smd7"
TIMEOUT=4

# Check if the device file exists and is a character special file
if [ ! -c "$DEVICE_FILE" ]; then
    echo "Error: Device $DEVICE_FILE does not exist or is not a character special file."
    exit 1
fi

# Ask for the AT command from the user
read -p "Enter AT command: " at_command

# Function to send the AT command to the device and read the response
send_at_command() {
    # Flush any existing content in the device buffer
    cat $DEVICE_FILE > /dev/null 2>&1 & 
    CAT_PID=$!
    sleep 0.1
    kill $CAT_PID
    wait $CAT_PID 2>/dev/null

    # Send the AT command to the device
    echo -e "${at_command}\r" > "$DEVICE_FILE"

    # Read the response for a certain time period
    (cat "$DEVICE_FILE" & sleep "$TIMEOUT"; kill $!) | {
        # Read from the pipe until there is no more data or timeout occurs
        while IFS= read -r line; do
            RESPONSE="${RESPONSE}${line}\n"
        done
        # After the subshell and background jobs are done, check if we got a response
        if [ -z "$RESPONSE" ]; then
            echo "Error: Response timed out."
        else
            echo "$RESPONSE"
        fi
    }
}

send_at_command
