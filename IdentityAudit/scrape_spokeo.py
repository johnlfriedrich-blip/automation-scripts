from Python.logger import setup_logger
from Python.config_loader import load_headers
from Python.parser import parse_spokeo
import requests
import time

logger = setup_logger("Logs/spokeo")

def fetch_page(url, headers, retries=3, delay=2):
    for attempt in range(1, retries + 1):
        try:
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            logger.info(f"Successfully fetched: {url}")
            return response.text
        except Exception as e:
            logger.warning(f"Attempt {attempt} failed: {e}")
            time.sleep(delay)
    logger.error(f"Failed to fetch after {retries} attempts: {url}")
    return None

def main():
    headers = load_headers("Config/spokeo_headers.json")
    url = "https://www.spokeo.com/search?q=John+Friedrich"
    html = fetch_page(url, headers)
    if html:
        parse_spokeo(html)

if __name__ == "__main__":
    main()