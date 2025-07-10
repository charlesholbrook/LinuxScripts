#!/bin/bash

SERVICE="mariadb"
LOGFILE="/var/log/mariadb_monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Check the service status
STATUS=$(systemctl is-active "$SERVICE")
FAILED=$(systemctl is-failed "$SERVICE")

if [[ "$STATUS" != "active" || "$FAILED" == "failed" ]]; then
    echo "$TIMESTAMP: $SERVICE is $STATUS / $FAILED. Attempting restart..." >> "$LOGFILE"
    systemctl restart "$SERVICE"
    sleep 5
    STATUS_AFTER=$(systemctl is-active "$SERVICE")
    if [[ "$STATUS_AFTER" == "active" ]]; then
        echo "$TIMESTAMP: Restart successful." >> "$LOGFILE"
    else
        echo "$TIMESTAMP: Restart failed. Service status is now $STATUS_AFTER." >> "$LOGFILE"
    fi
else
    echo "$TIMESTAMP: $SERVICE is running normally." >> "$LOGFILE"
fi
