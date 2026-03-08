import requests
from bs4 import BeautifulSoup
import mariadb
import sys
import os
from datetime import datetime

# Log file path
log_file = "/logs/price-log.log"
def log_message(message):
    """Write message to both log file and Docker stdout"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"{timestamp} {message}\n"
    # Append to log file
    try:
        with open(log_file, "a") as f:
            f.write(line)
    except Exception as e:
        print(f"Failed to write to log file: {e}")
    # Print to Docker logs
    print(line, end="")

# Website login from environment variables
USERNAME = os.getenv("ROMEOS_USER")
PASSWORD = os.getenv("ROMEOS_PASS")

# Database config from environment variables
db_config = {
    'host': os.getenv("DB_HOST"),
    'port': int(os.getenv("DB_PORT", 3306)),
    'user': os.getenv("DB_USER"),
    'password': os.getenv("DB_PASS"),
    'database': os.getenv("DB_NAME")
}

session = requests.Session()
login_url = "https://www.romeosfuel.com/loginAction"
login_payload = {"username": USERNAME, "password": PASSWORD}

try:
    login_response = session.post(login_url, data=login_payload)
    if login_response.status_code != 200 or "Invalid" in login_response.text:
        log_message("Login failed: check username/password")
        sys.exit(1)
    log_message("Login successful")
except requests.RequestException as e:
    log_message(f"Login request error: {e}")
    sys.exit(1)

dashboard_url = "https://www.romeosfuel.com/dashboardRedirectAction"
try:
    response = session.get(dashboard_url)
except requests.RequestException as e:
    log_message(f"Dashboard request error: {e}")
    sys.exit(1)

soup = BeautifulSoup(response.text, "html.parser")
price_element = soup.find("strong", class_="pricefont")

if not price_element:
    log_message("Price not found")
    sys.exit(1)

main = price_element.find(string=True, recursive=False).strip()
sup = price_element.find("sup")
price = main.replace("$", "") + sup.text.strip() if sup else main.replace("$", "")

now = datetime.now()
formatted_date = now.strftime("%Y-%m-%d")
formatted_time = now.strftime("%H:%M:%S")

conn = None
cursor = None

try:
    conn = mariadb.connect(**db_config)
    cursor = conn.cursor()
    insert_query = "INSERT INTO Price (Date, Time, Price) VALUES (%s, %s, %s)"
    cursor.execute(insert_query, (formatted_date, formatted_time, price))
    conn.commit()
    log_message(f"INSERT successful, changes committed. {formatted_date} {formatted_time} Fuel price: {price}")
except mariadb.Error as err:
    log_message(f"Database error: {err}")
    sys.exit(1)
finally:
    if cursor:
        cursor.close()
    if conn:
        conn.close()
    log_message("Database connection closed")
