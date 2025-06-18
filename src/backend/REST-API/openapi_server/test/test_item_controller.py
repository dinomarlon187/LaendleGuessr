import unittest
from unittest.mock import patch, MagicMock
from flask import json

from openapi_server.models.user_id import UserId  # noqa: E501
from openapi_server.test import BaseTestCase


class TestItemController(BaseTestCase):
    """ItemController integration test stubs"""

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_get(self, mock_supabase):
        """Test case for all_items_get

        Alle Items anzeigen
        """
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = [{'id': 1, 'name': 'Test Item'}]
        response = self.client.open('/item', method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))
        self.assertIsInstance(json.loads(response.data), list)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_owned_by(self, mock_supabase):
        """Test case for all_items_owned_by

        Alle Items eines Users bekommen
        """
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{'iid': 1}]
        response = self.client.open('/all_item_user/{uid}'.format(uid=1), method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))
        self.assertIsInstance(json.loads(response.data), list)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_get_found(self, mock_supabase):
        """Test case for item_get found

        Item mit bestimmter ID anzeigen
        """
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = {'id': 1, 'name': 'Test Item'}
        response = self.client.open('/item/{id}'.format(id=1), method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_get_not_found(self, mock_supabase):
        """Test case for item_get not found

        Item mit bestimmter ID nicht gefunden
        """
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/item/{id}'.format(id=999), method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post(self, mock_supabase):
        """Test case for item_user_post

        Einem User ein Item zuschreiben
        """
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'id': 1, 'uid': 1}
        response = self.client.open(
            '/item_user',
            method='POST',
            data=json.dumps(user_id),
            content_type='application/json')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
