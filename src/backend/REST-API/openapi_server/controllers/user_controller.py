import connexion
from openapi_server.models.user import User
from openapi_server.db import supabase
import bcrypt
from openapi_server.logger import logger


def all_users_get():
    logger.info("Abruf aller Benutzer gestartet.")
    response = supabase.table("user").select("*").execute()
    logger.info(f"{len(response.data) if response.data else 0} Benutzer gefunden.")
    return response.data, 200


def user_login():
    if not connexion.request.is_json:
        logger.warning("Login fehlgeschlagen: Anfrage nicht im JSON-Format.")
        return {"nachricht": "Anfrage muss im JSON-Format sein"}, 400

    data = connexion.request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        logger.warning("Login fehlgeschlagen: Benutzername oder Passwort fehlt.")
        return {"nachricht": "Benutzername und Passwort erforderlich"}, 400

    response = (
        supabase.table("user")
        .select("*")
        .eq("username", username)
        .single()
        .execute()
    )

    user = response.data
    if not user or not bcrypt.checkpw(password.encode("utf-8"), user["password"].encode("utf-8")):
        logger.warning(f"Login fehlgeschlagen für Benutzer: {username}")
        return {"nachricht": "Ungültiger Benutzername oder Passwort"}, 401

    logger.info(f"Benutzer {username} erfolgreich angemeldet.")
    return {
        "nachricht": "Anmeldung erfolgreich",
        "uid": user["uid"],
        "username": user["username"],
        "coins": user["coins"],
        "admin": user["admin"],
        "city": user["city"]
    }, 200



def user_get(id_):
    logger.info(f"Abruf von Benutzer mit ID {id_} gestartet.")
    try:
        response = (
            supabase.table("user")
            .select("*")
            .eq("uid", id_)
            .single()
            .execute()
        )
        if response.data:
            logger.info(f"Benutzer {id_} erfolgreich gefunden.")
            return response.data, 200
        else:
            logger.warning(f"Benutzer {id_} nicht gefunden.")
            return {"nachricht": "Benutzer nicht gefunden"}, 404
    except Exception as e:
        logger.error(f"Fehler beim Abrufen von Benutzer {id_}: {e}")
        return {"nachricht": "Datenbankfehler"}, 500


def user_post(body):
    logger.info("Benutzerregistrierung gestartet.")
    if not connexion.request.is_json:
        logger.warning("Benutzerregistrierung fehlgeschlagen: Anfrage nicht im JSON-Format.")
        return {"nachricht": "Anfrage muss im JSON-Format sein"}, 400

    try:
        user = User.from_dict(connexion.request.get_json())
        logger.info(f"Registrierungsversuch für Benutzer: {user.username}")

        if not user.username or not user.password:
            logger.warning("Benutzerregistrierung fehlgeschlagen: Benutzername oder Passwort fehlt.")
            return {"nachricht": "Benutzername und Passwort sind erforderlich"}, 400

        if len(user.password) < 8:
            logger.warning("Benutzerregistrierung fehlgeschlagen: Passwort zu kurz.")
            return {"nachricht": "Passwort muss mindestens 8 Zeichen lang sein"}, 400

        if " " in user.password:
            logger.warning("Benutzerregistrierung fehlgeschlagen: Passwort enthält Leerzeichen.")
            return {"nachricht": "Passwort darf keine Leerzeichen enthalten"}, 400

        if not isinstance(user.city, int) or not (0 <= user.city <= 4):
            logger.warning("Benutzerregistrierung fehlgeschlagen: Ungültige Stadt-ID.")
            return {"nachricht": "Ungültige Stadt-ID. Erlaubt sind Ganzzahlen von 0 bis 4."}, 400

        if user.admin not in [True, False]:
            logger.warning("Benutzerregistrierung fehlgeschlagen: Admin nicht boolesch.")
            return {"nachricht": "Admin muss True oder False sein"}, 400

        logger.info(f"Prüfe ob Benutzername {user.username} bereits existiert.")
        username_check = (
            supabase.table("user")
            .select("uid")
            .eq("username", user.username)
            .execute()
        )

        if username_check.data:
            logger.warning(f"Benutzerregistrierung fehlgeschlagen: Benutzername {user.username} existiert bereits.")
            return {"nachricht": "Benutzername existiert bereits"}, 409

        logger.info(f"Hashe Passwort für Benutzer {user.username}.")
        hashed_pw = bcrypt.hashpw(user.password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

        daten = {
            "username": user.username,
            "password": hashed_pw,
            "coins": user.coins or 0,
            "admin": user.admin,
            "city": user.city
        }

        logger.info(f"Erstelle Benutzer {user.username} in Datenbank.")
        response = supabase.table("user").insert(daten).execute()

        if response.data:
            logger.info(f"Benutzer {user.username} erfolgreich erstellt mit UID {response.data[0]['uid']}.")
            return {"nachricht": "Benutzer erfolgreich erstellt", "uid": response.data[0]["uid"]}, 201
        else:
            logger.error(f"Fehler beim Erstellen des Benutzers {user.username} - Keine Daten zurückgegeben.")
            return {"nachricht": "Fehler beim Erstellen des Benutzers"}, 500
    except Exception as e:
        logger.error(f"Unerwarteter Fehler bei Benutzerregistrierung: {e}")
        return {"nachricht": "Interner Serverfehler"}, 500


def user_update(id_):
    if not connexion.request.is_json:
        logger.warning("Benutzer-Update fehlgeschlagen: Anfrage nicht im JSON-Format.")
        return {"nachricht": "Anfrage muss im JSON-Format sein"}, 400

    user = User.from_dict(connexion.request.get_json())
    update_daten = {}

    if user.username:
        username_check = (
            supabase.table("user")
            .select("uid")
            .eq("username", user.username)
            .neq("uid", id_)
            .execute()
        )
        if username_check.data:
            logger.warning(f"Benutzer-Update fehlgeschlagen: Benutzername {user.username} existiert bereits.")
            return {"nachricht": "Benutzername existiert bereits"}, 409
        update_daten["username"] = user.username

    if user.password:
        if len(user.password) < 8:
            logger.warning("Benutzer-Update fehlgeschlagen: Passwort zu kurz.")
            return {"nachricht": "Passwort muss mindestens 8 Zeichen lang sein"}, 400
        if " " in user.password:
            logger.warning("Benutzer-Update fehlgeschlagen: Passwort enthält Leerzeichen.")
            return {"nachricht": "Passwort darf keine Leerzeichen enthalten"}, 400
        update_daten["password"] = bcrypt.hashpw(user.password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    if user.coins is not None:
        update_daten["coins"] = user.coins

    if user.admin is not None:
        if user.admin not in [True, False]:
            logger.warning("Benutzer-Update fehlgeschlagen: Admin nicht boolesch.")
            return {"nachricht": "Admin muss True oder False sein"}, 400
        update_daten["admin"] = user.admin

    if user.city is not None:
        if not isinstance(user.city, int) or not (0 <= user.city <= 4):
            logger.warning("Benutzer-Update fehlgeschlagen: Ungültige Stadt-ID.")
            return {"nachricht": "Ungültige Stadt-ID. Erlaubt sind Ganzzahlen von 0 bis 4."}, 400
        update_daten["city"] = user.city

    if not update_daten:
        logger.warning("Benutzer-Update fehlgeschlagen: Keine gültigen Felder zur Aktualisierung.")
        return {"nachricht": "Keine gültigen Felder zur Aktualisierung übergeben"}, 400

    response = (
        supabase.table("user")
        .update(update_daten)
        .eq("uid", id_)
        .execute()
    )

    if response.data:
        logger.info(f"Benutzer {id_} erfolgreich aktualisiert.")
        return {"nachricht": "Benutzer erfolgreich aktualisiert"}, 200
    else:
        logger.warning(f"Benutzer {id_} nicht gefunden oder nicht aktualisiert.")
        return {"nachricht": "Benutzer nicht gefunden oder nicht aktualisiert"}, 404
    
def get_all_time_stats(uid):
    """
    Gibt die Allzeit-Statistiken eines Users zurück
    """
    logger.info(f"Abruf der Allzeit-Statistiken für Benutzer {uid} gestartet.")
    
    try:
        user_response = (
            supabase.table("user")
            .select("uid")
            .eq("uid", uid)
            .single()
            .execute()
        )
        
        if not user_response.data:
            logger.warning(f"Benutzer {uid} nicht gefunden.")
            return {"nachricht": "Benutzer nicht gefunden"}, 404
        
        steps_response = (
            supabase.table("user_quest")
            .select("steps")
            .eq("uid", uid)
            .execute()
        )
        
        total_steps = sum(quest.get("steps", 0) for quest in steps_response.data)
        
        time_response = (
            supabase.table("user_quest")
            .select("timeInSeconds")
            .eq("uid", uid)
            .execute()
        )
        
        total_time_seconds = sum(quest.get("timeInSeconds", 0) for quest in time_response.data)
        
        stats = {
            "steps": total_steps,
            "timeInSeconds": total_time_seconds
        }
        
        logger.info(f"Allzeit-Statistiken für Benutzer {uid} erfolgreich abgerufen.")
        return stats, 200
        
    except Exception as e:
        logger.error(f"Fehler beim Abrufen der Allzeit-Statistiken für Benutzer {uid}: {e}")
        return {"nachricht": "Datenbankfehler"}, 500
