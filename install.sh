#!/bin/sh

service="/etc/init.d/discord-resolver"
tmp_file="/tmp/discord-resolver-crontab-tmp"

echo "[+] Installing dependencies..."
opkg update
opkg install coreutils-timeout conntrack

echo "[+] Installing script files..."
cp files/usr/bin/discord-resolver.sh /usr/bin/discord-resolver.sh
cp files/etc/init.d/discord-resolver "$service"
chmod +x "$service"

echo "[+] Setting up cron job..."
new_cron_job="0 5 * * * $service"
(crontab -l 2>/dev/null | grep -vF "$new_cron_job"; echo "$new_cron_job") | crontab -

echo "[+] Enabling service..."
/etc/init.d/discord-resolver enable

echo "[+] Done. Start the service with:"
echo "    /etc/init.d/discord-resolver start"

