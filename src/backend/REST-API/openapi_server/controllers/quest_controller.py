import connexion
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.user_id import UserId  # noqa: E501
from openapi_server import util
from openapi_server.db import supabase
from datetime import date


def all_quests_done_by(uid):  # noqa: E501
    response = (
        supabase.table("user_quest")
        .select("qid")
        .eq("uid", uid)
        .execute()
    )
    return response.data


def all_quests_get():  # noqa: E501
    response = (
        supabase.table("quest")
        .select("*")
        .execute()
    )
    return response.data


def dailyquest_get(city):  # noqa: E501
    response = (
        supabase.table("quest")
        .select("*")
        .eq("city",city)
        .eq("last_used_d",date.today().isoformat())
        .execute()
    )
    return response.data


def quest_user_post(body):  # noqa: E501
    """Einem User eine Quest als gemacht zuschreiben

     # noqa: E501

    :param user_id: 
    :type user_id: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user_id = body
    print(body)
    if connexion.request.is_json:
        user_id = UserId.from_dict(connexion.request.get_json())  # noqa: E501
    response = (
    supabase.table("user_quest")
    .insert({"qid": user_id.id,"uid" : user_id.uid})
    .execute()
)   
    return "Success", 200


def weeklyquest_get():  # noqa: E501
    """Derzeitige globale WeeklyQuest

     # noqa: E501


    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    today = date.today()
    iso_year, iso_week, _ = today.isocalendar()

    iso_string = f"{iso_year}-W{iso_week:02d}"
    response = (
        supabase.table("quest")
        .select("*")
        .eq("last_used_w",iso_string)
        .execute()
    )
    return response.data

def activequest_get(uid):
    response = (
        supabase.table("active_quest")
        .select("*")
        .eq("uid", uid)
        .execute()
    )
    if response.data:
        qid = response.data[0].get("qid")
        quest_response = (
            supabase.table("quest")
            .select("*")
            .eq("qid", qid)
            .single()
            .execute()
        )
        return quest_response.data, 200
    return None, 200

def activequest_post(body): 
    if connexion.request.is_json:
        data = connexion.request.get_json()
        uid = data.get("uid")
        qid = data.get("qid")
        response = (
            supabase.table("active_quest")
            .insert({"uid": uid, "qid": qid})
            .execute()
        )
        return "Success", 200
    return "Invalid input", 400

def activequest_delete(uid): 
    response = (
        supabase.table("active_quest")
        .delete()
        .eq("uid", uid)
        .execute()
    )
    return "Success", 200

def quest_get(qid): 
    response = (
        supabase.table("quest")
        .select("*")
        .eq("qid", qid)
        .single()
        .execute()
    )
    return response.data
