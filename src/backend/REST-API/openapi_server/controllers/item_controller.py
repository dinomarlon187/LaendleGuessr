"""
@file item_controller.py
@brief Controller für Item-bezogene API-Endpunkte im LaendleGuessr Backend.

Dieses Modul enthält Funktionen zur Verwaltung und Abfrage von Items und deren Zuordnung zu Benutzern.
Alle Funktionen sind für die REST-API vorgesehen und werden von OpenAPI genutzt.
"""

import connexion
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.user_id import UserId  # noqa: E501
from openapi_server import util

from openapi_server.db import supabase
from openapi_server.logger import logger


def all_items_get():  # noqa: E501
    """Alle Items anzeigen
    
    @brief Gibt eine Liste aller Items zurück.
    @return Liste aller Items aus der Datenbank.
    """
    logger.info("Abruf aller Items gestartet.")
    response = (
        supabase.table("item")
        .select("*")
        .execute()
    )
    logger.info(f"{len(response.data) if response.data else 0} Items gefunden.")
    return response.data


def all_items_owned_by(uid):  # noqa: E501
    """Alle Items eines Users bekommen
    
    @brief Gibt alle Items zurück, die einem bestimmten User gehören.
    @param uid: Die eindeutige User-ID
    @return Liste der Items, die dem User zugeordnet sind.
    """
    logger.info(f"Abruf aller Items für User {uid} gestartet.")
    try:
        response = (
            supabase.table("user_item")
            .select("item(*)")
            .eq("uid", uid)
            .execute()
        )
        items = [item['item'] for item in response.data if item.get('item')]
        logger.info(f"{len(items)} Items für User {uid} gefunden.")
        return items
    except Exception as e:
        logger.error(f"Fehler beim Abrufen der Items für User {uid}: {e}")
        return [], 500


def item_get(id):  # noqa: E501
    """Item mit bestimmter ID anzeigen
    
    @brief Gibt ein Item anhand seiner ID zurück.
    @param id: Die eindeutige Item-ID
    @return Das Item-Objekt oder Fehlercode.
    """
    logger.info(f"Abruf Item mit ID {id} gestartet.")
    try:
        response = (
            supabase.table("item")
            .select("*")
            .eq("id", id)
            .execute()
        )
        if response.data:
            logger.info(f"Item mit ID {id} erfolgreich gefunden.")
            return response.data[0]
        else:
            logger.warning(f"Item mit ID {id} nicht gefunden.")
            return None, 404
    except Exception as e:
        logger.error(f"Fehler beim Abrufen von Item {id}: {e}")
        return None, 500


def item_user_post(body):  # noqa: E501
    """Einem User ein Item zuschreiben
    
    @brief Verknüpft ein Item mit einem User.
    @param body: JSON-Objekt mit User- und Item-ID
    @return Erfolgs- oder Fehlermeldung
    """
    user_id = body
    logger.info(f"Item-Zuweisung gestartet: {body}")
    try:
        if connexion.request.is_json:
            user_id = UserId.from_dict(connexion.request.get_json())  # noqa: E501
        logger.info(f"Weise Item {user_id.id} User {user_id.uid} zu.")
        response = (
            supabase.table("user_item")
            .insert({"iid": user_id.id, "uid": user_id.uid})
            .execute()
        )
        logger.info(f"Item {user_id.id} erfolgreich User {user_id.uid} zugewiesen.")
        return "Success", 200
    except Exception as e:
        logger.error(f"Fehler bei Item-Zuweisung {user_id.id} zu User {user_id.uid}: {e}")
        return "Error", 500
