import requests
print("Infotracer Opt-Out Handler Loaded")
def opt_out_infotracer(name, email):
    url = "https://www.infotracer.com/privacy/"
    payload = {
        "full_name": name,
        "email": email
    }
    headers = {
        "User-Agent": "Mozilla/5.0"
    }

    response = requests.post(url, data=payload, headers=headers)
    return {
        "site": "Infotracer",
        "status_code": response.status_code,
        "success": response.ok
    }