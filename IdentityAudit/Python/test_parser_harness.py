from parser import parse_spokeo
from logger import setup_logger
from bs4 import BeautifulSoup

def test_parser():
    print("Test harness started.")
    logger = setup_logger("Logs/test_parser")

    try:
        with open("Config/sample_spokeo_page.html", "r", encoding="utf-8") as f:
            html = f.read()
        logger.info("Loaded sample HTML for parsing.")

        soup = BeautifulSoup(html, "html.parser")

        name = soup.find("h1", class_="name").text.strip()
        location = soup.find("p", class_="location").text.strip()
        details = [li.text.strip() for li in soup.find("ul", class_="details").find_all("li")]

        # Assertions
        assert name == "John Friedrich", f"Name mismatch: {name}"
        assert location == "Albuquerque, NM", f"Location mismatch: {location}"
        assert "Age: 42" in details, "Missing age detail"
        assert "Phone: (505) 555-1234" in details, "Missing phone detail"
        assert "Email: john.friedrich@example.com" in details, "Missing email detail"

        print("✅ All assertions passed.")
        logger.info("All assertions passed.")

    except AssertionError as ae:
        print(f"❌ Assertion failed: {ae}")
        logger.error(f"Assertion failed: {ae}")
    except Exception as e:
        print(f"❌ Test harness error: {e}")
        logger.error(f"Test harness error: {e}")

if __name__ == "__main__":
    test_parser()