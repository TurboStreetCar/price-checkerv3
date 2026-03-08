#!/bin/bash
set -e  # Exit immediately if a command fails

# 1. Start cron service
service cron start

# 2. Export ENV variables for cron
printenv | grep -v "no_proxy" >> /etc/environment

# 3. Ensure directories exist and copy files
mkdir -p /app/scripts/ /etc/cron.d/ /logs/

[ ! -f "/app/streamlit_app.py" ] && cp /tmp/base_app/scripts/streamlit_app.py /app/
[ ! -f "/etc/cron.d/fuel-cron" ] && cp /tmp/base_app/cron/fuel-cron /etc/cron.d/
[ ! -f "/app/scripts/price-checker.py" ] && cp /tmp/base_app/scripts/price-checker.py /app/scripts/

# 4. Copy latest samples
cp /tmp/base_app/scripts/test.py /app/scripts/
cp /tmp/base_app/cron/test-cron /etc/cron.d/

# 5. Set strict permissions (Cron requirement)
chmod 0644 /etc/cron.d/*
touch /var/log/cron.log

# 6. Execute CMD
exec "$@"
