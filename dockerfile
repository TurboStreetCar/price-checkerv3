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

# 3. Clone and install requirements
RUN git clone https://github.com/streamlit/streamlit-example.git /tmp/base_app/repo_clone
RUN pip3 install --no-cache-dir -r /tmp/base_app/repo_clone/requirements.txt

# 4. Copy your custom files into the temp staging area
COPY requirements2.txt /tmp/base_app/
COPY price-checker.py /tmp/base_app/scripts/
COPY streamlit_app.py /tmp/base_app/scripts/
COPY test.py /tmp/base_app/scripts/
COPY fuel-cron /tmp/base_app/cron/
COPY test-cron /tmp/base_app/cron/

# 5. Install extra requirements
RUN pip3 install --no-cache-dir -r /tmp/base_app/requirements2.txt

# 6. Setup entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8501

# Use the full path for the script just to be safe
ENTRYPOINT ["entrypoint.sh", "streamlit", "run", "/app/streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
