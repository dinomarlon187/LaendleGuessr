import unittest
from unittest.mock import patch, MagicMock
from flask import json
from openapi_server.models.user import User
from openapi_server.test import BaseTestCase


class TestUserController(BaseTestCase):
    """UserController integration test stubs"""

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_all_users_get(self, mock_supabase):
        """Test case for all_users_get

        Alle User anzeigen
        """
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = [{'uid': 1, 'username': 'testuser'}]
        response = self.client.open('/user', method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))
        self.assertIsInstance(json.loads(response.data), list)

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_get_found(self, mock_supabase):
        """Test case for user_get found

        User mit bestimmter ID anzeigen
        """
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = {'uid': 1, 'username': 'testuser'}
        response = self.client.open('/user/{id}'.format(id=1), method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))
        self.assertEqual(json.loads(response.data)['uid'], 1)

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_get_not_found(self, mock_supabase):
        """Test case for user_get not found

        Versuch, einen nicht vorhandenen Benutzer abzurufen
        """
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = None
        response = self.client.open('/user/{id}'.format(id=999), method='GET')
        self.assert404(response, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.user_controller.bcrypt')
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_post_success(self, mock_supabase, mock_bcrypt):
        """Test case for user_post success

        Neuen User erfolgreich hinzufügen
        """
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = [{'uid': 1}]
        mock_bcrypt.hashpw.return_value = b'hashed_password'
        user = {'username': 'newuser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open(
            '/user',
            method='POST',
            data=json.dumps(user),
            content_type='application/json')
        self.assertStatus(response, 201, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_post_username_exists(self, mock_supabase):
        """Test case for user_post username exists

        Versuch, einen User mit bereits vorhandenem Benutzernamen hinzuzufügen
        """
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{'uid': 1}]
        user = {'username': 'testuser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open(
            '/user',
            method='POST',
            data=json.dumps(user),
            content_type='application/json')
        self.assertStatus(response, 409, 'Response body is : ' + response.data.decode('utf-8'))

    def test_user_post_invalid_password(self):
        """Test case for user_post with invalid password"""
        user = {'username': 'newuser', 'password': 'pw', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', data=json.dumps(user), content_type='application/json')
        self.assert400(response, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.user_controller.bcrypt')
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_login_success(self, mock_supabase, mock_bcrypt):
        """Test case for user_login success

        Benutzeranmeldung mit gültigen Anmeldeinformationen
        """
        user_data = {'uid': 1, 'username': 'testuser', 'password': 'hashed_password', 'coins': 100, 'admin': False, 'city': 1}
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = user_data
        mock_bcrypt.checkpw.return_value = True
        credentials = {'username': 'testuser', 'password': 'password123'}
        response = self.client.open(
            '/user/login',
            method='POST',
            data=json.dumps(credentials),
            content_type='application/json')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))
        self.assertEqual(json.loads(response.data)['uid'], 1)

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_login_not_found(self, mock_supabase):
        """Test case for user_login not found

        Anmeldung mit nicht vorhandenem Benutzernamen
        """
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = None
        credentials = {'username': 'nouser', 'password': 'password123'}
        response = self.client.open(
            '/user/login',
            method='POST',
            data=json.dumps(credentials),
            content_type='application/json')
        self.assert401(response, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.user_controller.bcrypt')
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_login_wrong_password(self, mock_supabase, mock_bcrypt):
        """Test case for user_login wrong password

        Anmeldung mit falschem Passwort
        """
        user_data = {'uid': 1, 'username': 'testuser', 'password': 'hashed_password', 'coins': 100, 'admin': False, 'city': 1}
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = user_data
        mock_bcrypt.checkpw.return_value = False
        credentials = {'username': 'testuser', 'password': 'wrongpassword'}
        response = self.client.open(
            '/user/login',
            method='POST',
            data=json.dumps(credentials),
            content_type='application/json')
        self.assert401(response, 'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
