"""
@file quest_controller.py
@brief Controller für Quest-bezogene API-Endpunkte im LaendleGuessr Backend.

Dieses Modul enthält Funktionen zur Verwaltung und Abfrage von Quests, deren Zuweisung und Status für Benutzer.
Alle Funktionen sind für die REST-API vorgesehen und werden von OpenAPI genutzt.
"""

import connexion
from typing import Dict
from typing import Tuple
from typing import Union
from openapi_server.models.user_id import UserId  # noqa: E501
from openapi_server import util
from openapi_server.db import supabase
from datetime import date
from openapi_server.logger import logger


def all_quests_done_by(uid):  # noqa: E501
    """
    @brief Gibt alle erledigten Quests eines Benutzers zurück.
    @param uid: Die eindeutige User-ID
    @return Liste der erledigten Quests
    """
    logger.info(f"Abruf aller erledigten Quests für User {uid}.")
    response = (
        supabase.table("user_quest")
        .select("qid")
        .eq("uid", uid)
        .execute()
    )
    logger.info(f"{len(response.data) if response.data else 0} Quests gefunden.")
    return response.data


def all_quests_get():  # noqa: E501
    """
    @brief Gibt eine Liste aller Quests zurück.
    @return Liste aller Quests aus der Datenbank.
    """
    logger.info("Abruf aller Quests gestartet.")
    response = (
        supabase.table("quest")
        .select("*")
        .execute()
    )
    logger.info(f"{len(response.data) if response.data else 0} Quests gefunden.")
    return response.data


def dailyquest_get(city):  # noqa: E501
    """
    @brief Gibt die aktuelle DailyQuest für eine bestimmte Stadt zurück.
    @param city: Name der Stadt
    @return DailyQuest-Objekt oder leere Liste
    """
    logger.info(f"Abruf der DailyQuest für Stadt {city} gestartet.")
    try:
        response = (
            supabase.table("quest")
            .select("*")
            .eq("city",city)
            .eq("last_used_d", date.today())
            .execute()
        )
        if response.data:
            logger.info(f"DailyQuest für Stadt {city} gefunden: {len(response.data)} Quest(s).")
            return response.data
        else:
            logger.warning(f"Keine DailyQuest für Stadt {city} am {date.today()} gefunden.")
            return []
    except Exception as e:
        logger.error(f"Fehler beim Abrufen der DailyQuest für Stadt {city}: {e}")
        return [], 500


def quest_user_post(body):  # noqa: E501
    """
    @brief Verknüpft eine Quest mit einem User als abgeschlossen.
    @param body: JSON-Objekt mit User- und Quest-ID
    @return Erfolgs- oder Fehlermeldung
    """
    user_id = body
    logger.info(f"Quest-Zuweisung gestartet: {body}")
    try:
        if connexion.request.is_json:
            user_id = UserId.from_dict(connexion.request.get_json())  # noqa: E501
        logger.info(f"Weise Quest {user_id.id} User {user_id.uid} zu.")
        response = (
        supabase.table("user_quest")
        .insert({"qid": user_id.id,"uid" : user_id.uid})
        .execute()
    )   
        logger.info(f"Quest {user_id.id} erfolgreich User {user_id.uid} zugewiesen.")
        return "Success", 200
    except Exception as e:
        logger.error(f"Fehler bei Quest-Zuweisung {user_id.id} zu User {user_id.uid}: {e}")
        return "Error", 500


def weeklyquest_get():  # noqa: E501
    """
    @brief Gibt die aktuelle WeeklyQuest zurück.
    @return WeeklyQuest-Objekt oder leere Liste
    """
    try:
        today = date.today()
        iso_year, iso_week, _ = today.isocalendar()
        iso_string = f"{iso_year}-W{iso_week:02d}"
        logger.info(f"Abruf der WeeklyQuest für Woche {iso_string} gestartet.")
        response = (
            supabase.table("quest")
            .select("*")
            .eq("last_used_w",iso_string)
            .execute()
        )
        if response.data:
            logger.info(f"WeeklyQuest für Woche {iso_string} gefunden: {len(response.data)} Quest(s).")
        else:
            logger.warning(f"Keine WeeklyQuest für Woche {iso_string} gefunden.")
        return response.data
    except Exception as e:
        logger.error(f"Fehler beim Abrufen der WeeklyQuest: {e}")
        return [], 500


def activequest_get(uid):
    """
    @brief Gibt die aktuell aktive Quest eines Benutzers zurück.
    @param uid: Die eindeutige User-ID
    @return Aktive Quest-Objekt oder None
    """
    logger.info(f"Abruf der aktiven Quest für User {uid} gestartet.")
    try:
        response = (
            supabase.table("active_quest")
            .select("*")
            .eq("uid", uid)
            .execute()
        )
        if response.data:
            qid = response.data[0].get("qid")
            logger.info(f"Aktive Quest {qid} für User {uid} gefunden, lade Quest-Details.")
            quest_response = (
                supabase.table("quest")
                .select("*")
                .eq("qid", qid)
                .single()
                .execute()
            )
            logger.info(f"Quest-Details für aktive Quest {qid} erfolgreich geladen.")
            return quest_response.data, 200
        logger.info(f"Keine aktive Quest für User {uid} gefunden.")
        return None, 200
    except Exception as e:
        logger.error(f"Fehler beim Abrufen der aktiven Quest für User {uid}: {e}")
        return None, 500


def activequest_post(body): 
    """
    @brief Setzt eine neue aktive Quest für einen Benutzer.
    @param body: JSON-Objekt mit User- und Quest-ID
    @return Erfolgs- oder Fehlermeldung
    """
    logger.info(f"Setze aktive Quest: {body}")
    try:
        if connexion.request.is_json:
            data = connexion.request.get_json()
            uid = data.get("uid")
            qid = data.get("qid")
            logger.info(f"Setze Quest {qid} als aktive Quest für User {uid}.")
            response = (
                supabase.table("active_quest")
                .insert({"uid": uid, "qid": qid})
                .execute()
            )
            logger.info(f"aktive Quest für User {uid} erfolgreich gesetzt.")
            return "Success", 200
        logger.warning("activequest_post: Ungültige Eingabe.")
        return "Invalid input", 400
    except Exception as e:
        logger.error(f"Fehler beim Setzen der aktiven Quest für User {uid}: {e}")
        return "Error", 500


def activequest_delete(uid): 
    """
    @brief Entfernt die aktuell aktive Quest eines Benutzers.
    @param uid: Die eindeutige User-ID
    @return Erfolgs- oder Fehlermeldung
    """
    logger.info(f"Lösche aktive Quest für User {uid}.")
    response = (
        supabase.table("active_quest")
        .delete()
        .eq("uid", uid)
        .execute()
    )
    return "Success", 200


def quest_get(qid): 
    """
    @brief Gibt eine Quest anhand ihrer ID zurück.
    @param qid: Die eindeutige Quest-ID
    @return Quest-Objekt
    """
    logger.info(f"Abruf der Quest mit ID {qid}.")
    response = (
        supabase.table("quest")
        .select("*")
        .eq("qid", qid)
        .single()
        .execute()
    )
    return response.data


def activequest_started_get(uid):
    """
    @brief Gibt den Startzeitpunkt der aktiven Quest eines Benutzers zurück.
    @param uid: Die eindeutige User-ID
    @return Startzeitpunkt als Dictionary
    """
    logger.info(f"Abruf des Startzeitpunkts der aktiven Quest für User {uid}.")
    response = (
        supabase.table("active_quest")
        .select("started_at")
        .eq("uid", uid)
        .single()
        .execute()
    )
    if response.data:
        started_at = response.data.get("started_at")
        return {"started_at": started_at}, 200
    
def activequest_update_stepCount(uid, body):
    """
    @brief Aktualisiert die Schrittanzahl der aktiven Quest eines Benutzers.
    @param uid: Die eindeutige User-ID
    @param body: JSON-Objekt mit neuer Schrittanzahl
    @return Erfolgs- oder Fehlermeldung
    """
    steps = body.get('step_count')
    if steps is None:
        logger.warning(f"activequest_update_stepCount: step_count fehlt für User {uid}.")
        return "Missing step_count in body", 400
    logger.info(f"Update Schrittanzahl für User {uid}: {steps}")
    response = (
        supabase.table("active_quest")
        .update({"stepsCount": steps})
        .eq("uid", uid)
        .execute()
    )
    if response.data:
        logger.info(f"Schrittanzahl für User {uid} erfolgreich aktualisiert.")
        return "Step count updated successfully", 200
    logger.warning(f"Fehler beim Update der Schrittanzahl für User {uid}.")
    return "Failed to update step count", 400

def activequest_get_stepCount(uid):
    """
    @brief Gibt die aktuelle Schrittanzahl der aktiven Quest eines Benutzers zurück.
    @param uid: Die eindeutige User-ID
    @return Schrittanzahl als Dictionary
    """
    logger.info(f"Abruf Schrittanzahl für User {uid}.")
    response = (
        supabase.table("active_quest")
        .select("stepsCount")
        .eq("uid", uid)
        .single()
        .execute()
    )
    if response.data:
        steps_count = response.data.get("stepsCount")
        return {"steps": steps_count}, 200