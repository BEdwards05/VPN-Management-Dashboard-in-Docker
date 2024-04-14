#!/bin/bash

#Set DNS to Google by default
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Configure reverse proxy with caddy
cat << EOF > /etc/caddy/Caddyfile
{
    local_certs
}
${ADMIN_DOMAIN:-example.com} {
    reverse_proxy localhost:5000
}
EOF
caddy start --config /etc/caddy/Caddyfile --adapter caddyfile
echo "Reverse proxy configured with caddy."

# Create the configWireguard.py or configOpenVPN.py
cat << EOF > configWireguard.py
wireGuardBlockAds = ${ADBLOCK:-True}
EOF
echo "configureWireguard.py file created for AdBlock settings."

# Create the config.py
passwordhash=$(echo -n ${ADMIN_PASSWORD:-admin} | sha256sum | cut -d" " -f1)

cat << EOF > /app/config.py
import ${VPN_TYPE:-wireguard} as vpn
creds = {
    "username": "${ADMIN_USERNAME:-admin}",
    "password": "$passwordhash",
}
EOF
if [ -f "/app/config.py" ]; then
    echo "config.py file created successfully."
else
    echo "Failed to create config.py file."
fi

# Download vpn setup script
wget https://raw.githubusercontent.com/Nyr/${VPN_TYPE:-wireguard}-install/master/${VPN_TYPE:-wireguard}-install.sh -O vpn-install.sh
echo "VPN setup script downloaded."

# Setup vpn
chmod +x vpn-install.sh
bash vpn-install.sh <<< 'auto'
echo "VPN service installed."

# Run web admin portal
exec python3 /app/main.py
echo "Web admin portal started at ${ADMIN_DOMAIN:-example.com}"
echo "Done!"
