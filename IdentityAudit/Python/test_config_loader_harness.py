from config_loader import load_headers
from logger import setup_logger

def test_config_loader():
    print("Config loader test started.")
    logger = setup_logger("Logs/test_config")

    try:
        config = load_headers("Config/sample_config.json")
        logger.info("Loaded config: %s", config)

        # Assertions
        assert isinstance(config, dict), "Config is not a dictionary"
        assert "target_url" in config, "Missing 'target_url' key"
        assert config["target_url"].startswith("http"), "Invalid URL format"
        assert config.get("timeout", 0) > 0, "Timeout must be positive"
        assert config.get("retry", 0) >= 0, "Retry must be non-negative"

        print("✅ Config loader passed.")
        logger.info("Config loader passed.")

    except AssertionError as ae:
        print(f"❌ Assertion failed: {ae}")
        logger.error(f"Assertion failed: {ae}")
    except Exception as e:
        print(f"❌ Config loader error: {e}")
        logger.error(f"Config loader error: {e}")

if __name__ == "__main__":
    test_config_loader()