#!/bin/bash

# 1. Start the cron service in the background
service cron start

# 2. Export environment variables for cron
# Cron jobs run in a restricted shell and won't see your Docker ENV variables 
# unless we explicitly save them to /etc/environment.
printenv | grep -v "no_proxy" >> /etc/environment

# 3. Existing logic: Check if streamlit_app.py exists
if [ ! -f "/app/streamlit_app.py" ]; then
    echo "Share is empty. Copying default streamlit App..."
    cp -rp /tmp/base_app/streamlit_app.py /app/
fi

# 4. Existing logic: Check if cron file exists
if [ ! -f "/etc/cron.d/fuel-cron" ]; then
    echo "Cron is empty. Copying default cron file..."
    cp -rp /tmp/base_app/fuel-cron /app/
fi

# 5. Execute the streamlit command passed from Dockerfile
exec "$@"
