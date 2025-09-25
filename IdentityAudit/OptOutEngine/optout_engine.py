import os
import json
from dotenv import load_dotenv
from datetime import datetime
from handlers.infotracer import opt_out_infotracer
from handlers.emailtracer import opt_out_emailtracer
from handlers.searchusapeople import opt_out_searchusapeople
from handlers.governmentregistry import opt_out_governmentregistry
from handlers.ndb import opt_out_ndb
from handlers.peoplelookup import opt_out_peoplelookup

config_path = os.path.join(os.path.dirname(__file__), "..", "Config", "experian_sites.json")
with open(config_path) as f:
    sites = json.load(f)

# Load environment variables
load_dotenv()

def validate_env_vars(required_keys):
    missing = [key for key in required_keys if not os.getenv(key)]
    if missing:
        raise EnvironmentError(f"Missing required .env keys: {', '.join(missing)}")

try:
    validate_env_vars(["SENDER_EMAIL", "SMTP_SERVER", "SMTP_PORT", "SMTP_PASSWORD"])
except EnvironmentError as e:
    print(f"❌ Environment validation failed: {e}")
    exit(1)

def run_opt_out(name, email):
    # Load SMTP config from .env
    sender_email = os.getenv("SENDER_EMAIL", "john.friedrich@example.com")
    smtp_config = {
        "smtp_server": os.getenv("SMTP_SERVER", "smtp.gmail.com"),
        "smtp_port": int(os.getenv("SMTP_PORT", 465)),
        "smtp_password": os.getenv("SMTP_PASSWORD", "your-app-password"),
    }

    # Load site registry
    with open("Config/experian_sites.json") as f:
        sites = json.load(f)

    results = []

    for site in sites:
        try:
            if site["site"] == "Infotracer":
                result = opt_out_infotracer(name, email)
            elif site["site"] == "EmailTracer":
                result = opt_out_emailtracer(name, email, sender_email, **smtp_config)
            elif site["site"] == "SearchUSAPeople":
                result = opt_out_searchusapeople(name, email)
            elif site["site"] == "GovernmentRegistry":
                result = opt_out_governmentregistry(name, email)
            elif site["site"] == "NDB":
                result = opt_out_ndb(name, email)
            elif site["site"] == "PeopleLookUp":
                result = opt_out_peoplelookup(name, email, sender_email, smtp_config)
            else:
                result = {"site": site["site"], "status": "unsupported"}
        except Exception as e:
            result = {"site": site["site"], "error": str(e)}

        results.append(result)

    return results

def log_results(results, log_dir="Logs"):
    os.makedirs(log_dir, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    log_path = os.path.join(log_dir, f"optout_{timestamp}.json")
    with open(log_path, "w") as f:
        json.dump(results, f, indent=2)

if __name__ == "__main__":
    results = run_opt_out("John Friedrich", "johnlfriedrich@gmail.com")
    print(json.dumps(results, indent=2))
    log_results(results)