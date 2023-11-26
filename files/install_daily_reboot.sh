#!/bin/sh

# Function to create systemd service and timer files with the user-specified time
create_service_and_timer() {
    # Create the systemd service file for reboot
    echo "[Unit]
Description=Reboot Modem Daily

[Service]
Type=oneshot
ExecStart=/bin/echo -e 'AT+CFUN=1,1 \r' > /dev/smd7
Restart=no
RemainAfterExit=no" > /lib/systemd/system/rebootmodem.service

    # Create the systemd timer file with the user-specified time
    echo "[Unit]
Description=Starts rebootmodem.service daily at the specified time

[Timer]
OnCalendar=*-*-* $user_time:00
Persistent=false" > /lib/systemd/system/rebootmodem.timer

    # Create a trigger service that starts the timer at boot
    echo "[Unit]
Description=Trigger the rebootmodem timer at boot

[Service]
Type=oneshot
ExecStart=/bin/systemctl start rebootmodem.timer
RemainAfterExit=yes" > /lib/systemd/system/rebootmodem-trigger.service

    # Create symbolic links for the trigger service in the wanted directory
    ln -sf /lib/systemd/system/rebootmodem-trigger.service /lib/systemd/system/multi-user.target.wants/

    # Reload systemd to recognize the new timer and trigger service
    systemctl daemon-reload
    sleep 2s

    # Start the trigger service, which will start the timer
    systemctl start rebootmodem-trigger.service

    # Confirmation
    echo "Rebootmodem-trigger service created and started successfully."
    echo "Reboot schedule set successfully. The modem will reboot daily at $user_time UTC."
}

# Main script starts here
# Remount root filesystem as read-write
mount -o remount,rw /

# Check if the rebootmodem service, timer, or trigger already exists
if [ -f /lib/systemd/system/rebootmodem.service ] || [ -f /lib/systemd/system/rebootmodem.timer ] || [ -f /lib/systemd/system/rebootmodem-trigger.service ]; then
    printf "The rebootmodem service/timer/trigger is already installed. Do you want to change or remove it? (change/remove): "
    read user_action

    case $user_action in
        remove)
            # Stop and disable timer and trigger service by removing symlinks
            systemctl stop rebootmodem.timer
            systemctl stop rebootmodem-trigger.service

            # Remove symbolic links and files
            rm -f /lib/systemd/system/multi-user.target.wants/rebootmodem-trigger.service
            rm -f /lib/systemd/system/rebootmodem.service
            rm -f /lib/systemd/system/rebootmodem.timer
            rm -f /lib/systemd/system/rebootmodem-trigger.service

            # Reload systemd to apply changes
            systemctl daemon-reload

            echo "Rebootmodem service, timer, and trigger removed successfully."
            ;;
        change)
            printf "Enter the new time for daily reboot (24-hour format in Coordinated Universal Time, HH:MM): "
            read new_time

            # Validate the new time format using grep
            if ! echo "$new_time" | grep -qE '^([01]?[0-9]|2[0-3]):[0-5][0-9]$'; then
                echo "Invalid time format. Exiting."
                exit 1
            else
                # Remove old symlinks
                rm -f /lib/systemd/system/multi-user.target.wants/rebootmodem-trigger.service
                
                # Set the user time to the new time and recreate the service, timer, and trigger
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
