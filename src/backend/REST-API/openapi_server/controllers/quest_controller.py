import connexion
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.user_id import UserId  # noqa: E501
from openapi_server import util


def all_quests_done_by(uid):  # noqa: E501
    """Alle gemachten Quests eines users bekommen

     # noqa: E501

    :param uid: 
    :type uid: int

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'


def all_quests_get():  # noqa: E501
    """Alle Quests bekommen

     # noqa: E501


    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'


def dailyquest_get(city):  # noqa: E501
    """Derzeitige DailyQuest einer Stadt

     # noqa: E501

    :param city: 
    :type city: int

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'


def quest_user_post(body):  # noqa: E501
    """Einem User eine Quest als gemacht zuschreiben

     # noqa: E501

    :param user_id: 
    :type user_id: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user_id = body
    if connexion.request.is_json:
        user_id = UserId.from_dict(connexion.request.get_json())  # noqa: E501
    return 'do some magic!'


def weeklyquest_get():  # noqa: E501
    """Derzeitige globale WeeklyQuest

     # noqa: E501


    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'
