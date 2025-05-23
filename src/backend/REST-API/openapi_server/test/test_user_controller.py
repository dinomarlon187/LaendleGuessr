import unittest

from flask import json

from openapi_server.models.user import User  # noqa: E501
from openapi_server.test import BaseTestCase


class TestUserController(BaseTestCase):
    """UserController integration test stubs"""

    def test_all_users_get(self):
        """Test case for all_users_get

        Alle User anzeigen
        """
        headers = { 
        }
        response = self.client.open(
            '/user',
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_user_get(self):
        """Test case for user_get

        User mit bestimmter ID anzeigen
        """
        headers = { 
        }
        response = self.client.open(
            '/user/{id}'.format(id=56),
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_user_post(self):
        """Test case for user_post

        Neuen User hinzufügen
        """
        user = openapi_server.User()
        headers = { 
            'Content-Type': 'application/json',
        }
        response = self.client.open(
            '/user',
            method='POST',
            headers=headers,
            data=json.dumps(user),
            content_type='application/json')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_user_update(self):
        """Test case for user_update

        User bearbeiten
        """
        headers = { 
        }
        response = self.client.open(
            '/user/{id}'.format(id=56),
            method='PUT',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
