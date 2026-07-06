FROM python:3.9-slim

WORKDIR /app

# 1. Install dependencies
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    build-essential \
    libmariadb-dev-compat \
    libmariadb-dev \
    curl \
    git \
    cron \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup temp directory structure
RUN mkdir -p /tmp/base_app/scripts /tmp/base_app/cron 

# 6. Setup entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the full path for the script just to be safe
ENTRYPOINT ["entrypoint.sh"]
