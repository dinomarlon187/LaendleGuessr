from openapi_server.__main__ import main
from openapi_server.logger import logger

if __name__ == "__main__":
    logger.info("start_server.py: Server wird über start_server.py gestartet")
    main()
    logger.info("start_server.py: Server-Start abgeschlossen")