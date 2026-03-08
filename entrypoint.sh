#!/bin/bash

# 1. Start the cron service in the background
service cron start

# 2. Export environment variables for cron
# Cron jobs run in a restricted shell and won't see your Docker ENV variables 
# unless we explicitly save them to /etc/environment.
printenv | grep -v "no_proxy" >> /etc/environment

# 3. Existing logic: Check if streamlit_app.py exists
if [ ! -f "/app/streamlit_app.py" ]; then
    echo "Share is empty. Copying default files..."
    cp -rp /tmp/base_app/. /app/
fi

# 4. Execute the streamlit command passed from Dockerfile
exec "$@"
