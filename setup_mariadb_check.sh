#!/bin/bash

# Variables
SCRIPT_DIR="/root/scripts"
SCRIPT_URL="https://core-docs.s3.us-east-1.amazonaws.com/documents/asset/uploaded_file/2813/KEDC/5865302/check_mariadb.txt"
SCRIPT_FILE="$SCRIPT_DIR/check_mariadb.sh"
LOGROTATE_CONF="/etc/logrotate.d/mariadb_monitor"
LOG_FILE="/var/log/mariadb_monitor.log"
CRON_ENTRY="*/5 * * * * $SCRIPT_FILE"

# Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "❌ Please run this script as root."
    exit 1
fi

echo "📁 Creating script directory..."
mkdir -p "$SCRIPT_DIR"

echo "⬇️ Downloading mariadb check script..."
curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_FILE"
if [[ ! -f "$SCRIPT_FILE" ]]; then
    echo "❌ Failed to download script."
    exit 1
fi

echo "✅ Script downloaded. Making it executable..."
chmod +x "$SCRIPT_FILE"

echo "🕒 Setting up cron job..."
CRONTAB_TMP=$(mktemp)
crontab -l > "$CRONTAB_TMP" 2>/dev/null
if ! grep -Fxq "$CRON_ENTRY" "$CRONTAB_TMP"; then
    echo "$CRON_ENTRY" >> "$CRONTAB_TMP"
    crontab "$CRONTAB_TMP"
    echo "✅ Cron job added."
else
    echo "⚠️ Cron job already exists."
fi
rm -f "$CRONTAB_TMP"

echo "📝 Setting up log rotation for $LOG_FILE..."
cat <<EOF > "$LOGROTATE_CONF"
/var/log/mariadb_monitor.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 640 root adm
}
EOF

echo "✅ Log rotation configured at: $LOGROTATE_CONF"
echo "✅ Setup complete."
