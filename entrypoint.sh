#!/bin/bash
set -e  # Exit immediately if a command fails

# 1. Start cron service
service cron start

# 2. Export ENV variables for cron
printenv | grep -v "no_proxy" >> /etc/environment

# 3. Ensure directories exist
mkdir -p /app/scripts/ /etc/cron.d/ /logs/ 

# 4. Set strict permissions (Cron requirement)
chmod 0644 /etc/cron.d/*
touch /var/log/cron.log

# 5. Execute CMD
exec "$@"
