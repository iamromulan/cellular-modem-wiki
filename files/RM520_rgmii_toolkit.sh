#!/bin/sh

# Define paths
USRDATA_DIR="/usrdata"
MICROPYTHON_DIR="/usrdata/micropython"
AT_TELNET_DIR="/usrdata/at-telnet"
SIMPLE_ADMIN_DIR="/usrdata/simpleadmin"
TMP_DIR="/tmp"
GITHUB_URL="https://github.com/iamromulan/quectel-rgmii-simpleadmin-at-telnet-daemon/archive/refs/heads/main.zip"

# AT Command Script Variables and Functions
DEVICE_FILE="/dev/smd7"
TIMEOUT=4  # Set a timeout for the response

start_listening() {
    cat "$DEVICE_FILE" > /tmp/device_readout &
    CAT_PID=$!
}

send_at_command() {
    echo "Enter AT command (or type 'exit' to quit): "
    read at_command
    if [ "$at_command" = "exit" ]; then
        return 1
    fi
    echo -e "${at_command}\r" > "$DEVICE_FILE"
}

wait_for_response() {
    local start_time=$(date +%s)
    local current_time
    local elapsed_time

    echo "Command sent, waiting for response..."
    while true; do
        if grep -qe "OK" -e "ERROR" /tmp/device_readout; then
            echo "Response received:"
            cat /tmp/device_readout
            return 0
        fi
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ "$elapsed_time" -ge "$TIMEOUT" ]; then
            echo "Error: Response timed out."
            return 1
        fi
        sleep 1
    done
}

cleanup() {
    kill "$CAT_PID"
    wait "$CAT_PID" 2>/dev/null
    rm -f /tmp/device_readout
}

send_at_commands() {
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
}

# Check if AT Telnet Daemon is installed
is_at_telnet_installed() {
    [ -d "$MICROPYTHON_DIR" ] && return 0 || return 1
	[ -d "$AT_TELNET_DIR" ] && return 0 || return 1
}

# Check if Simple Admin is installed
is_simple_admin_installed() {
    [ -d "$SIMPLE_ADMIN_DIR" ] && return 0 || return 1
}

# Function to remount file system as read-write
remount_rw() {
    mount -o remount,rw /
}

# Function to remount file system as read-only
remount_ro() {
    mount -o remount,ro /
}

# Function to install/update AT Telnet Daemon
install_update_at_telnet() {
    remount_rw
    cd $TMP_DIR
    wget $GITHUB_URL -O main.zip
    unzip -o main.zip
    cp -Rf quectel-rgmii-simpleadmin-at-telnet-daemon-main/attelnetdaemon/at-telnet $USRDATA_DIR
	cp -Rf quectel-rgmii-simpleadmin-at-telnet-daemon-main/attelnetdaemon/micropython $USRDATA_DIR

    # Set execute permissions
    chmod +x $MICROPYTHON_DIR/micropython
    chmod +x $AT_TELNET_DIR/modem-multiclient.py
    chmod +x $AT_TELNET_DIR/socat-armel-static
    chmod +x $AT_TELNET_DIR/picocom

    # Copy systemd unit files & reload
    cp -f $AT_TELNET_DIR/systemd_units/*.service /lib/systemd/system
    systemctl daemon-reload

    # Link systemd files
    ln -sf /lib/systemd/system/at-telnet-daemon.service /lib/systemd/system/multi-user.target.wants/
    ln -sf /lib/systemd/system/socat-smd11.service /lib/systemd/system/multi-user.target.wants/
    ln -sf /lib/systemd/system/socat-smd11-to-ttyIN.service /lib/systemd/system/multi-user.target.wants/
    ln -sf /lib/systemd/system/socat-smd11-from-ttyIN.service /lib/systemd/system/multi-user.target.wants/
    # Start Services
    systemctl start socat-smd11
    sleep 2s
    systemctl start socat-smd11-to-ttyIN
    systemctl start socat-smd11-from-ttyIN
    systemctl start at-telnet-daemon

    remount_ro
}

# Function to remove AT Telnet Daemon
remove_at_telnet() {
    remount_rw
    systemctl stop at-telnet-daemon
    systemctl disable at-telnet-daemon
    rm -rf $MICROPYTHON_DIR
	rm -rf $AT_TELNET_DIR
    rm /lib/systemd/system/at-telnet-daemon.service
    rm /lib/systemd/system/socat-smd11.service
    rm /lib/systemd/system/socat-smd11-to-ttyIN.service
    rm /lib/systemd/system/socat-smd11-from-ttyIN.service
    systemctl daemon-reload
    remount_ro
}

# Function to install/update Simple Admin
install_update_simple_admin() {
    remount_rw
    cd $TMP_DIR
    wget $GITHUB_URL -O main.zip
    unzip -o main.zip
    cp -Rf quectel-rgmii-simpleadmin-at-telnet-daemon-main/simpleadmin/ $USRDATA_DIR

    # Set execute permissions
    chmod +x $SIMPLE_ADMIN_DIR/scripts/*
    chmod +x $SIMPLE_ADMIN_DIR/www/cgi-bin/*
    chmod +x $SIMPLE_ADMIN_DIR/ttl/ttl-override

    # Copy systemd unit files & reload
    cp -f $SIMPLE_ADMIN_DIR/systemd/* /lib/systemd/system
    systemctl daemon-reload

    # Link systemd files
    ln -sf /lib/systemd/system/simpleadmin_httpd.service /lib/systemd/system/multi-user.target.wants/
    ln -sf /lib/systemd/system/simpleadmin_generate_status.service /lib/systemd/system/multi-user.target.wants/
    ln -sf /lib/systemd/system/ttl-override.service /lib/systemd/system/multi-user.target.wants/
    # Start Services
    systemctl start simpleadmin_generate_status
    systemctl start simpleadmin_httpd
    systemctl start ttl-override

    remount_ro
}

# Function to remove Simple Admin
remove_simple_admin() {
    remount_rw
    systemctl stop simpleadmin_httpd
    systemctl disable simpleadmin_httpd
    rm -rf $SIMPLE_ADMIN_DIR
    rm /lib/systemd/system/simpleadmin_httpd.service
    rm /lib/systemd/system/simpleadmin_generate_status.service
    rm /lib/systemd/system/ttl-override.service
    systemctl daemon-reload
    remount_ro
}

# Function to create systemd service and timer files with the user-specified time
create_service_and_timer() {
    # Create the systemd service file for reboot
    echo "[Unit]
Description=Reboot Modem Daily

[Service]
Type=oneshot
ExecStart=/sbin/reboot
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

# Function to manage Daily Reboot Timer
manage_reboot_timer() {
    # Remount root filesystem as read-write
    mount -o remount,rw /

    # Check if the rebootmodem service, timer, or trigger already exists
    if [ -f /lib/systemd/system/rebootmodem.service ] || [ -f /lib/systemd/system/rebootmodem.timer ] || [ -f /lib/systemd/system/rebootmodem-trigger.service ]; then
        echo "The rebootmodem service/timer/trigger is already installed."
        echo "1) Change"
        echo "2) Remove"
        read -p "Enter your choice (1 for Change, 2 for Remove): " reboot_choice

        case $reboot_choice in
            2)
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
            1)
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
                echo "Invalid choice. Exiting."
                exit 1
                ;;
        esac
    else
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
}

# Main menu
while true; do
    echo "Select an option:"
    echo "1) Send AT Commands"
    echo "2) Install/Update or remove AT Telnet Daemon"
    echo "3) Install/Update or remove Simple Admin"
    echo "4) Install/Change or remove Daily Reboot Timer"
    echo "5) Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            send_at_commands
            ;;
        2)
            if is_at_telnet_installed; then
                echo "AT Telnet Daemon is already installed."
                echo "1) Update"
                echo "2) Remove"
                read -p "Enter your choice: " at_telnet_choice
                case $at_telnet_choice in
                    1) install_update_at_telnet;;
                    2) remove_at_telnet;;
                    *) echo "Invalid option";;
                esac
            else
                echo "Installing AT Telnet Daemon..."
                install_update_at_telnet
            fi
            ;;
        3)
            if is_simple_admin_installed; then
                echo "Simple Admin is already installed."
                echo "1) Update"
                echo "2) Remove"
                read -p "Enter your choice: " simple_admin_choice
                case $simple_admin_choice in
                    1) install_update_simple_admin;;
                    2) remove_simple_admin;;
                    *) echo "Invalid option";;
                esac
            else
                echo "Installing Simple Admin..."
                install_update_simple_admin
            fi
            ;;
        4)
            manage_reboot_timer
            ;;
        5) 
            break
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done

echo "Exiting script."

