import connexion
from openapi_server.models.user import User
from openapi_server.db import supabase
import bcrypt


def all_users_get():
    response = supabase.table("user").select("*").execute()
    return response.data, 200


def user_get(id_):
    response = (
        supabase.table("user")
        .select("*")
        .eq("uid", id_)
        .single()
        .execute()
    )
    if response.data:
        return response.data, 200
    else:
        return {"nachricht": "Benutzer nicht gefunden"}, 404


def user_post(body):
    if not connexion.request.is_json:
        return {"nachricht": "Anfrage muss im JSON-Format sein"}, 400

    user = User.from_dict(connexion.request.get_json())

    if not user.username or not user.password:
        return {"nachricht": "Benutzername und Passwort sind erforderlich"}, 400

    if len(user.password) < 8:
        return {"nachricht": "Passwort muss mindestens 8 Zeichen lang sein"}, 400

    if " " in user.password:
        return {"nachricht": "Passwort darf keine Leerzeichen enthalten"}, 400

    if not isinstance(user.city, int) or not (0 <= user.city <= 4):
        return {"nachricht": "Ungültige Stadt-ID. Erlaubt sind Ganzzahlen von 0 bis 4."}, 400

    if user.admin not in [True, False]:
        return {"nachricht": "Admin muss True oder False sein"}, 400

    username_check = (
        supabase.table("user")
        .select("uid")
        .eq("username", user.username)
        .execute()
    )

    if username_check.data:
        return {"nachricht": "Benutzername existiert bereits"}, 409

    hashed_pw = bcrypt.hashpw(user.password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    daten = {
        "username": user.username,
        "password": hashed_pw,
        "coins": user.coins or 0,
        "admin": user.admin,
        "city": user.city
    }

    response = supabase.table("user").insert(daten).execute()

    if response.data:
        return {"nachricht": "Benutzer erfolgreich erstellt", "uid": response.data[0]["uid"]}, 201
    else:
        return {"nachricht": "Fehler beim Erstellen des Benutzers"}, 500


def user_update(id_):
    if not connexion.request.is_json:
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
            return {"nachricht": "Benutzername existiert bereits"}, 409
        update_daten["username"] = user.username

    if user.password:
        if len(user.password) < 8:
            return {"nachricht": "Passwort muss mindestens 8 Zeichen lang sein"}, 400
        if " " in user.password:
            return {"nachricht": "Passwort darf keine Leerzeichen enthalten"}, 400
        update_daten["password"] = bcrypt.hashpw(user.password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    if user.coins is not None:
        update_daten["coins"] = user.coins

    if user.admin is not None:
        if user.admin not in [True, False]:
            return {"nachricht": "Admin muss True oder False sein"}, 400
        update_daten["admin"] = user.admin

    if user.city is not None:
        if not isinstance(user.city, int) or not (0 <= user.city <= 4):
            return {"nachricht": "Ungültige Stadt-ID. Erlaubt sind Ganzzahlen von 0 bis 4."}, 400
        update_daten["city"] = user.city

    if not update_daten:
        return {"nachricht": "Keine gültigen Felder zur Aktualisierung übergeben"}, 400

    response = (
        supabase.table("user")
        .update(update_daten)
        .eq("uid", id_)
        .execute()
    )

    if response.data:
        return {"nachricht": "Benutzer erfolgreich aktualisiert"}, 200
    else:
        return {"nachricht": "Benutzer nicht gefunden oder nicht aktualisiert"}, 404
