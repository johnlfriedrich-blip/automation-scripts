import os

def generate_mock_html(variant="missing_name"):
    base = """<!DOCTYPE html>
<html>
  <body>
    {name}
    {location}
    {details}
  </body>
</html>"""

    variants = {
        "missing_name": {
            "name": "",
            "location": '<p class="location">Albuquerque, NM</p>',
            "details": '<ul class="details"><li>Age: 42</li></ul>'
        },
        "missing_details": {
            "name": '<h1 class="name">John Friedrich</h1>',
            "location": '<p class="location">Albuquerque, NM</p>',
            "details": ""
        },
        "malformed_html": {
            "name": '<h1 class="name">John Friedrich',
            "location": '<p class="location">Albuquerque, NM',
            "details": '<ul class="details"><li>Age: 42'
        }
    }

    html = base.format(**variants.get(variant, variants["missing_name"]))
    path = f"Config/mock_{variant}.html"
    with open(path, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"Generated mock HTML: {path}")

if __name__ == "__main__":
    generate_mock_html("malformed_html")