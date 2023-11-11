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

[Install]
WantedBy=timers.target" > /lib/systemd/system/rebootmodem.timer

    # Create a service to ensure the timer starts on boot
    echo "[Unit]
Description=Ensure rebootmodem.timer is started on boot
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'while ! systemctl is-active --quiet rebootmodem.timer; do systemctl start rebootmodem.timer; sleep 5; done; echo \"rebootmodem.timer has been started.\" >> /var/log/rebootmodem.timer.log'
RemainAfterExit=no

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/start-rebootmodem-timer.service

    # Reload systemd to recognize the new service and timer
    systemctl daemon-reload
    sleep 2s

    # Enable and start the timer and its boot service
    systemctl enable rebootmodem.timer
    systemctl start rebootmodem.timer
    systemctl enable start-rebootmodem-timer.service

    # Confirmation
    echo "Reboot schedule and boot service set successfully. The modem will reboot daily at $user_time UTC (Coordinated Universal Time)."
}

# Main script starts here
# Remount root filesystem as read-write
mount -o remount,rw /

# Check if the rebootmodem timer already exists
if systemctl list-timers --all | grep -q 'rebootmodem.timer'; then
    printf "The daily reboot timer is already installed. Do you want to change or remove it? (change/remove): "
    read user_action

    case $user_action in
        remove)
            # Stop and disable the timer and its boot service
            systemctl stop rebootmodem.timer
            systemctl disable rebootmodem.timer
            systemctl stop start-rebootmodem-timer.service
            systemctl disable start-rebootmodem-timer.service

            # Remove the service, timer, and boot service files
            rm /lib/systemd/system/rebootmodem.service
            rm /lib/systemd/system/rebootmodem.timer
            rm /etc/systemd/system/start-rebootmodem-timer.service

            # Reload systemd to apply changes
            systemctl daemon-reload

            echo "Daily reboot timer and boot service removed successfully."
            ;;
        change)
            printf "Enter the new time for daily reboot (24-hour format in Coordinated Universal Time, HH:MM): "
            read new_time

            # Validate the new time format using grep
            if ! echo "$new_time" | grep -qE '^([01]?[0-9]|2[0-3]):[0-5][0-9]$'; then
                echo "Invalid time format. Exiting."
                exit 1
            else
                # Set the user time to the new time and recreate timer and boot service
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
    printf "Enter the time for daily reboot (24-hour format in Coordinated Universal Time, HH:MM): "
    read user_time

    # Validate the time format using grep
    if ! echo "$user_time" | grep -qE '^([01]?[0-9]|2[0-3]):[0-5][0-9]$'; then
        echo "Invalid time format. Exiting."
        exit 1
    else
        create_service_and_timer
    fi
fi

# Remount root filesystem as read-only
mount -o remount,ro /

# Delete this script
rm -- "$0"
