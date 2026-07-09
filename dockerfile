# Use the official Playwright base image (pre-configured with browser system libraries)
FROM mcr.microsoft.com/playwright/python:v1.45.0-jammy


WORKDIR /app

# 1. Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    libmariadb-dev-compat \
    libmariadb-dev \
    curl \
    git \
    cron \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup temp directory structure
RUN mkdir -p /tmp/base_app/scripts /tmp/base_app/cron 

# 3. Copy your custom files into the temp staging area
COPY requirements2.txt /tmp/base_app/

# 4. Install extra requirements
RUN pip3 install --no-cache-dir -r /tmp/base_app/requirements2.txt

# 5. Download the headless Chromium browser binaries explicitly into the image layer
# This prevents Playwright from attempting to download them at runtime when cron triggers
RUN playwright install chromium

# 6. Setup entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the full path for the script just to be safe
ENTRYPOINT ["entrypoint.sh"]
