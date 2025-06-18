from connexion.apps.flask_app import FlaskJSONEncoder
from openapi_server.logger import logger

from openapi_server.models.base_model import Model


class JSONEncoder(FlaskJSONEncoder):
    include_nulls = False

    def default(self, o):
        logger.debug(f"encoder.py: JSONEncoder.default() aufgerufen für Objekt vom Typ {type(o)}")
        if isinstance(o, Model):
            logger.debug(f"encoder.py: Serialisiere Model-Objekt {o.__class__.__name__}")
            dikt = {}
            for attr in o.openapi_types:
                value = getattr(o, attr)
                if value is None and not self.include_nulls:
                    logger.debug(f"encoder.py: Überspringe None-Wert für Attribut {attr}")
                    continue
                attr = o.attribute_map[attr]
                dikt[attr] = value
                logger.debug(f"encoder.py: Attribut {attr} hinzugefügt mit Wert: {value}")
            logger.debug(f"encoder.py: Model-Serialisierung abgeschlossen: {dikt}")
            return dikt
        logger.debug(f"encoder.py: Verwende Standard-Encoder für {type(o)}")
        return FlaskJSONEncoder.default(self, o)
