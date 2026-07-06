#!/bin/bash
set -e  # Exit immediately if a command fails

# 1. Export ENV variables for cron
printenv | grep -v "no_proxy" >> /etc/environment

# 2. Ensure directories exist
mkdir -p /app/scripts/ /etc/cron.d/ /logs/ 

# 3. Set strict permissions (Cron requirement)
chmod 0644 /etc/cron.d/*
touch /var/log/cron.log

# 4. Keep container alive with cron in the foreground
# If a specific command was passed to the container, run it.
# Otherwise, start cron in the foreground.
if [ $# -gt 0 ]; then
    exec "$@"
else
    echo "Starting cron in the foreground..."
    exec cron -f
fi
