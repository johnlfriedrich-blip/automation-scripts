import json
from handlers.infotracer import opt_out_infotracer
from handlers.emailtracer import opt_out_emailtracer

def run_opt_out(name, email, sender_email=None, smtp_config=None):
    if sender_email is None:
        sender_email = "john.friedrich@example.com"

    if smtp_config is None:
        smtp_config = {
            "smtp_server": "smtp.gmail.com",
            "smtp_port": 465,
            "smtp_password": "your-app-password"
        }

    with open("config/smtp_config.json") as f:
        smtp_config = json.load(f)
    sender_email = smtp_config.pop("sender_email")

    with open("config/experian_sites.json") as f:
        sites = json.load(f)

    print("Loaded sites:", sites)  # ✅ This is the correct spot

    results = []
    for site in sites:
        if site["method"] == "form":
            result = opt_out_infotracer(name, email)
        elif site["method"] == "email":
            print(f"Sending opt-out email from {sender_email} to {site['opt_out_email']}")
            result = opt_out_emailtracer(name, email, sender_email, **smtp_config)
        else:
            result = { "site": site["site"], "error": "Unknown method" }

        results.append(result)

    return results
    
# ✅ This block must be OUTSIDE the function
if __name__ == "__main__":
    results = run_opt_out("John Friedrich", "johnlfriedrich@gmail.com")
    print(json.dumps(results, indent=2))