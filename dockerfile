FROM python:3.9-slim

WORKDIR /app

# 1. Added 'cron' to your existing dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Clone to temporary location
RUN git clone https://github.com/streamlit/streamlit-example.git /tmp/base_app
RUN pip3 install -r /tmp/base_app/requirements.txt

# Add additional requirements
COPY requirements2.txt /tmp/base_app
RUN pip3 install -r /tmp/base_app/requirements2.txt

# 2. Add the cron job file
# Requirement: Filename MUST NOT have an extension (e.g., 'my-cron', NOT 'my-cron.txt')
COPY fuel-cron /etc/cron.d/fuel-cron

# 3. Set strict permissions (required by cron) and register it
RUN chmod 0644 /etc/cron.d/fuel-cron && \
    crontab /etc/cron.d/fuel-cron && \
    touch /var/log/cron.log

# Add the initialization script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8501

ENTRYPOINT ["entrypoint.sh", "streamlit", "run", "streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]


