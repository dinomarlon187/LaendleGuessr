import connexion
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.user import User  # noqa: E501
from openapi_server import util

import os
from supabase import create_client, Client

url: str = os.environ.get("https://ipjfhqmcqlwlrjqanjqk.supabase.co")
key: str = os.environ.get("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwamZocW1jcWx3bHJqcWFuanFrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NzUxNDA0NCwiZXhwIjoyMDYzMDkwMDQ0fQ.5VpSCVmfUZ02Tbs5fHPL5vJsfJqvC_s6CggESbRCQQs")
supabase: Client = create_client(url, key)

def all_users_get():  # noqa: E501
    """Alle User anzeigen

     # noqa: E501


    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'


def user_get(id):  # noqa: E501
    """User mit bestimmter ID anzeigen

     # noqa: E501

    :param id: 
    :type id: int

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'


def user_post(body):  # noqa: E501
    """Neuen User hinzufügen

     # noqa: E501

    :param user: 
    :type user: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user = body
    if connexion.request.is_json:
        user = User.from_dict(connexion.request.get_json())  # noqa: E501
    return 'do some magic!'


def user_update(id):  # noqa: E501
    """User bearbeiten

     # noqa: E501

    :param id: 
    :type id: int

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'
