#!/bin/sh

script_name=discord-resolver.sh
service_name=discord-resolver-service
script=/opt/discord-resolver/$script_name
service=/etc/init.d/$service_name

echo "[+] Installing dependencies..."
opkg update
opkg install coreutils-timeout conntrack

echo "[+] Installing script files..."
mkdir -p "$(dirname "$script")"
cp "$script_name" "$script"
cp "$service_name" "$service"
chmod +x "$script" "$service"

echo "[+] Setting up cron job..."
new_cron_job="0 5 * * * $script start"
(crontab -l 2>/dev/null | grep -vF "$new_cron_job"; echo "$new_cron_job") | crontab -

echo "[+] Enabling service..."
"$service" enable

echo "[+] Done. Start the service with:"
echo "    $service start"

