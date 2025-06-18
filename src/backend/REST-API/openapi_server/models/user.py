"""
@file user.py
@brief Model-Klasse für Benutzer im LaendleGuessr Backend.

Dieses Modul enthält die User-Klasse mit allen Attributen und Methoden zur Serialisierung und Validierung.
"""

from datetime import date, datetime
from typing import List, Dict
from openapi_server.models.base_model import Model
from openapi_server import util
from openapi_server.logger import logger

class User(Model):
    def __init__(self, username=None, password=None, coins=None, admin=None, city=None):
        logger.debug(f"models/user.py: User-Objekt erstellt mit username={username}, coins={coins}, admin={admin}, city={city}")
        self.openapi_types = {
            'username': str,
            'password': str,
            'coins': int,
            'admin': bool,
            'city': int
        }

        self.attribute_map = {
            'username': 'username',
            'password': 'password',
            'coins': 'coins',
            'admin': 'admin',
            'city': 'city'
        }

        self._username = username
        self._password = password
        self._coins = coins
        self._admin = admin
        self._city = city

    @classmethod
    def from_dict(cls, dikt) -> 'User':
        logger.debug(f"models/user.py: User.from_dict() aufgerufen mit: {dikt}")
        user = util.deserialize_model(dikt, cls)
        logger.debug(f"models/user.py: User-Objekt aus Dictionary erstellt: {user.username}")
        return user

    @property
    def username(self) -> str:
        return self._username

    @username.setter
    def username(self, username: str):
        if username is None:
            raise ValueError("Ungültiger Wert für `username`, darf nicht `None` sein")
        self._username = username

    @property
    def password(self) -> str:
        return self._password

    @password.setter
    def password(self, password: str):
        if password is None:
            raise ValueError("Ungültiger Wert für `password`, darf nicht `None` sein")
        self._password = password

    @property
    def coins(self) -> int:
        return self._coins

    @coins.setter
    def coins(self, coins: int):
        if coins is not None and coins < 0:
            raise ValueError("Ungültiger Wert für `coins`, muss >= 0 sein")
        self._coins = coins

    @property
    def admin(self) -> bool:
        return self._admin

    @admin.setter
    def admin(self, admin: bool):
        self._admin = admin

    @property
    def city(self) -> int:
        return self._city

    @city.setter
    def city(self, city: int):
        if city is not None and (not isinstance(city, int) or city < 0 or city > 4):
            raise ValueError("Ungültiger Wert für `city`, muss zwischen 0 und 4 liegen")
        self._city = city
