print("logger.py loaded")
import logging
from datetime import datetime

def setup_logger(log_prefix):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_path = f"{log_prefix}_{timestamp}.log"
    logging.basicConfig(
        filename=log_path,
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s"
    )
    return logging.getLogger("spokeo_logger")