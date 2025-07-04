#!/usr/bin/env python3
"""
@file __main__.py
@brief Einstiegspunkt für das LaendleGuessr Backend.

Dieses Modul startet den Backend-Server und initialisiert die API.
"""

import connexion
from openapi_server import encoder
from openapi_server.logger import logger


def main():
    """
    @brief Startet den Backend-Server und initialisiert die API.
    """
    logger.info("Backend-Server wird gestartet.")
    try:
        app = connexion.App(__name__, specification_dir='./openapi/')
        app.app.json_encoder = encoder.JSONEncoder
        app.add_api('openapi.yaml',
                    arguments={'title': 'LaendleGuessr'},
                    pythonic_params=True)
        logger.info("API und Encoder erfolgreich initialisiert.")
        app.run(port=8080)
    except Exception as e:
        logger.exception(f"Fehler beim Starten des Servers: {e}")
        raise


if __name__ == '__main__':
    main()
