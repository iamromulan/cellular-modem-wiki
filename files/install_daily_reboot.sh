#!/bin/sh

# Function to create systemd service and timer files with the user-specified time
create_service_and_timer() {
    # Create the systemd service file
    echo "[Unit]
Description=Reboot Modem Daily

[Service]
Type=oneshot
ExecStart=/sbin/reboot" > /lib/systemd/system/rebootmodem.service

    # Create the systemd timer file with the user-specified time
    echo "[Unit]
Description=Daily reboot timer

[Timer]
OnCalendar=*-*-* $user_time:00
Persistent=true

[Install]
WantedBy=timers.target" > /lib/systemd/system/rebootmodem.timer

    # Remount root filesystem as read-only
    mount -o remount,ro /

    # Reload systemd to recognize the new service and timer
    systemctl daemon-reload
    sleep 2s

    # Enable and start the timer
    systemctl enable rebootmodem.timer
    systemctl start rebootmodem.timer

    # Confirmation
    echo "Reboot schedule set successfully. The modem will reboot daily at $user_time."
}

# Check if the rebootmodem timer already exists
if systemctl list-timers --all | grep -q 'rebootmodem.timer'; then
    printf "The daily reboot timer is already installed. Do you want to change or remove it? (change/remove): "
    read user_action

    case $user_action in
        remove)
            # Stop and disable the timer
            systemctl stop rebootmodem.timer
            systemctl disable rebootmodem.timer

            # Remove the service and timer files
            rm /lib/systemd/system/rebootmodem.service
            rm /lib/systemd/system/rebootmodem.timer

            # Remount root filesystem as read-only
            mount -o remount,ro /

            # Reload systemd to apply changes
            systemctl daemon-reload

            echo "Daily reboot timer removed successfully."
            ;;
        change)
            printf "Enter the new time for daily reboot (24-hour format, HH:MM): "
            read new_time

            # Validate the new time format using grep
            if ! echo "$new_time" | grep -qE '^([01]?[0-9]|2[0-3]):[0-5][0-9]$'; then
                echo "Invalid time format. Exiting."
                exit 1
            else
                # Set the user time to the new time
                user_time=$new_time
                create_service_and_timer
            fi
            ;;
        *)
            echo "Invalid action. Exiting."
            exit 1
            ;;
    esac
else
    # Prompt user for the time since timer doesn't exist
    printf "Enter the time for daily reboot (24-hour format, HH:MM): "
    read user_time

    # Validate the time format using grep
    if ! echo "$user_time" | grep -qE '^([01]?[0-9]|2[0-3]):[0-5][0-9]$'; then
        echo "Invalid time format. Exiting."
        exit 1
    else
        create_service_and_timer
    fi
fi
