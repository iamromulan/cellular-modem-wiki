#!/bin/sh

# Function to create systemd service and timer files with the user-specified time
create_service_and_timer() {
    # Create the systemd service file
    echo "[Unit]
Description=Reboot Modem Daily

[Service]
Type=oneshot
ExecStart=/sbin/reboot
RemainAfterExit=no" > /lib/systemd/system/rebootmodem.service

    # Create the systemd timer file with the user-specified time
    echo "[Unit]
Description=Daily reboot timer

[Timer]
OnCalendar=*-*-* $user_time:00

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/rebootmodem.timer

    # Manually create symbolic links for the timer in the wanted directory
    ln -sf /lib/systemd/system/rebootmodem.timer /lib/systemd/system/multi-user.target.wants/

    # Reload systemd to recognize the new timer
    systemctl daemon-reload
    sleep 2s

    # Start the timer
    systemctl start rebootmodem.timer

    # Confirmation
    echo "Reboot schedule set successfully. The modem will reboot daily at $user_time UTC."
}

# Main script starts here
# Remount root filesystem as read-write
mount -o remount,rw /

# Check if the rebootmodem service or timer already exists
if [ -f /lib/systemd/system/rebootmodem.service ] || [ -f /lib/systemd/system/rebootmodem.timer ]; then
    printf "The daily reboot service/timer is already installed. Do you want to change or remove it? (change/remove): "
    read user_action

    case $user_action in
        remove)
            # Stop and disable timer by removing symlink
            systemctl stop rebootmodem.timer

            # Remove symbolic links and files
            rm -f /lib/systemd/system/multi-user.target.wants/rebootmodem.timer
            rm -f /lib/systemd/system/rebootmodem.service
            rm -f /lib/systemd/system/rebootmodem.timer

            # Reload systemd to apply changes
            systemctl daemon-reload

            echo "Daily reboot timer removed successfully."
            ;;
        change)
            printf "Enter the new time for daily reboot (24-hour format in Coordinated Universal Time, HH:MM): "
            read new_time

            # Validate the new time format using grep
            if ! echo "$new_time" | grep -qE '^([01]?[0-9]|2[0-3]):[0-5][0-9]$'; then
                echo "Invalid time format. Exiting."
                exit 1
            else
                # Remove old symlink
                rm -f /lib/systemd/system/multi-user.target.wants/rebootmodem.timer
                
                # Set the user time to the new time and recreate the timer and service files
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
    printf "Enter the time for daily reboot (24-hour format in UTC, HH:MM): "
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

# Self-delete the script
rm -- "$0"
