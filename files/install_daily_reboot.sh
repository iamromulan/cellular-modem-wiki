#!/bin/sh

# Remount root filesystem as read-write
mount -o remount,rw /

# Prompt user for input
printf "Enter the time for daily reboot (24-hour format, HH:MM): "
read user_time

# Use grep to validate the time format
echo "$user_time" | grep -qE '^([01]?[0-9]|2[0-3]):[0-5][0-9]$'
if [ $? -ne 0 ]; then
    echo "Invalid time format. Exiting."
    exit 1
fi

# Create the systemd service file
echo "[Unit]
Description=Reboot Modem Daily

[Service]
Type=oneshot
ExecStart=/sbin/reboot" > /lib/systemd/system/rebootmodem.service

# Create the systemd timer file
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
