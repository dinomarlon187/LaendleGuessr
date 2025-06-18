# flake8: noqa
"""
@file __init__.py
@brief Initialisiert das models-Paket für das LaendleGuessr Backend.

Dieses Modul importiert alle Model-Klassen für die REST-API.
"""

# import models into model package
from openapi_server.models.user import User
from openapi_server.models.user_id import UserId
from openapi_server.models.quest_user import QuestUser
