#!/bin/sh

# Remount root filesystem as read-write
mount -o remount,rw /

# Prompt user for input
read -p "Enter the time for daily reboot (24-hour format, HH:MM): " user_time

# Check if the user input is valid
if [[ ! "$user_time" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
    echo "Invalid time format. Exiting."
    exit 1
fi

# Create the systemd service file
cat > /lib/systemd/system/rebootmodem.service <<EOF
[Unit]
Description=Reboot Modem Daily

[Service]
Type=oneshot
ExecStart=/sbin/reboot
EOF

# Create the systemd timer file
cat > /lib/systemd/system/rebootmodem.timer <<EOF
[Unit]
Description=Daily reboot timer

[Timer]
OnCalendar=*-*-* $user_time:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Remount root filesystem as read-only
mount -o remount,ro /

# Enable and start the timer
systemctl enable rebootmodem.timer
systemctl start rebootmodem.timer

# Confirmation
echo "Reboot schedule set successfully. The modem will reboot daily at $user_time."
