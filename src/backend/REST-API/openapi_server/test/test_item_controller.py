import unittest

from flask import json

from openapi_server.models.user_id import UserId  # noqa: E501
from openapi_server.test import BaseTestCase


class TestItemController(BaseTestCase):
    """ItemController integration test stubs"""

    def test_all_items_get(self):
        """Test case for all_items_get

        Alle Items anzeigen
        """
        headers = { 
        }
        response = self.client.open(
            '/item',
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_all_items_owned_by(self):
        """Test case for all_items_owned_by

        Alle Items eines Users bekommen
        """
        headers = { 
        }
        response = self.client.open(
            '/all_item_user/{uid}'.format(uid=56),
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_item_get(self):
        """Test case for item_get

        Item mit bestimmter ID anzeigen
        """
        headers = { 
        }
        response = self.client.open(
            '/item/{id}'.format(id=56),
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_item_user_post(self):
        """Test case for item_user_post

        Einem User ein Item zuschreiben
        """
        user_id = openapi_server.UserId()
        headers = { 
            'Content-Type': 'application/json',
        }
        response = self.client.open(
            '/item_user',
            method='POST',
            headers=headers,
            data=json.dumps(user_id),
            content_type='application/json')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
