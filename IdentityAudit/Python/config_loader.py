import json

def load_headers(path):
    try:
        with open(path, "r") as f:
            return json.load(f)
    except Exception as e:
        print(f"Failed to load headers: {e}")
        return {}