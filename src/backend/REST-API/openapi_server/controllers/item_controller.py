import connexion
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.user_id import UserId  # noqa: E501
from openapi_server import util

import os
from supabase import create_client, Client

url: str = os.environ.get("https://ipjfhqmcqlwlrjqanjqk.supabase.co")
key: str = os.environ.get("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwamZocW1jcWx3bHJqcWFuanFrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NzUxNDA0NCwiZXhwIjoyMDYzMDkwMDQ0fQ.5VpSCVmfUZ02Tbs5fHPL5vJsfJqvC_s6CggESbRCQQs")
supabase: Client = create_client(url, key)

def all_items_get():  # noqa: E501
    """Alle Items anzeigen

     # noqa: E501


    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'


def all_items_owned_by(uid):  # noqa: E501
    """Alle Items eines Users bekommen

     # noqa: E501

    :param uid: 
    :type uid: int

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'


def item_get(id):  # noqa: E501
    """Item mit bestimmter ID anzeigen

     # noqa: E501

    :param id: 
    :type id: int

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'


def item_user_post(body):  # noqa: E501
    """Einem User ein Item zuschreiben

     # noqa: E501

    :param user_id: 
    :type user_id: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user_id = body
    if connexion.request.is_json:
        user_id = UserId.from_dict(connexion.request.get_json())  # noqa: E501
    return 'do some magic!'
