from bs4 import BeautifulSoup

def parse_spokeo(html):
    soup = BeautifulSoup(html, "html.parser")

    name = soup.find("h1", class_="name")
    location = soup.find("p", class_="location")
    details = soup.find("ul", class_="details")

    print("Name:", name.text.strip() if name else "Not found")
    print("Location:", location.text.strip() if location else "Not found")

    if details:
        for li in details.find_all("li"):
            print("Detail:", li.text.strip())
    else:
        print("Details not found")