"""
@file logger.py
@brief Logging-Konfiguration für das LaendleGuessr Backend.

Dieses Modul initialisiert das Logging für das Backend und schreibt Logs in eine Datei und auf die Konsole.
"""

import logging
import os

# Log-Verzeichnis und -Datei
log_dir = os.path.join(os.path.dirname(__file__), '../../logs')
os.makedirs(log_dir, exist_ok=True)
log_file = os.path.join(log_dir, 'backend.log')

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger('LaendleGuessrBackend')
