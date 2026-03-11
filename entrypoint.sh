#!/bin/bash
set -e  # Exit immediately if a command fails

# 1. Start cron service
service cron start

# 2. Export ENV variables for cron
printenv | grep -v "no_proxy" >> /etc/environment

# 3. Ensure directories exist
mkdir -p /app/scripts/ /app/www/ /etc/cron.d/ /logs/ 

[ ! -f "/app/www/streamlit_app.py" ] && cp /tmp/base_app/www/streamlit_app.py /app/www/

# 5. Set strict permissions (Cron requirement)
chmod 0644 /etc/cron.d/*
touch /var/log/cron.log

# 6. Execute CMD
exec "$@"
