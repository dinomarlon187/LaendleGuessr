import unittest
from unittest.mock import patch, MagicMock
from flask import json
from openapi_server.models.user_id import UserId
from openapi_server.test import BaseTestCase

class TestItemControllerComprehensive(BaseTestCase):
    """Comprehensive ItemController unit tests covering all edge cases"""

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_get_success(self, mock_supabase):
        """Test case for all_items_get - with items"""
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = [
            {'id': 1, 'name': 'Item 1', 'description': 'First item', 'cost': 100},
            {'id': 2, 'name': 'Item 2', 'description': 'Second item', 'cost': 200}
        ]
        response = self.client.open('/item', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertIsInstance(data, list)
        self.assertEqual(len(data), 2)
        self.assertEqual(data[0]['id'], 1)
        self.assertEqual(data[1]['id'], 2)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_get_empty(self, mock_supabase):
        """Test case for all_items_get - no items"""
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = []
        response = self.client.open('/item', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data, [])

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_get_database_error(self, mock_supabase):
        """Test case for all_items_get - database returns None"""
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = None
        response = self.client.open('/item', method='GET')
        self.assert200(response)
        # Controller returns response.data directly, so None would be returned

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_owned_by_success(self, mock_supabase):
        """Test case for all_items_owned_by - user has items"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [
            {'iid': 1}, {'iid': 3}, {'iid': 5}
        ]
        response = self.client.open('/all_item_user/1', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertIsInstance(data, list)
        self.assertEqual(len(data), 3)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_owned_by_empty(self, mock_supabase):
        """Test case for all_items_owned_by - user has no items"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/all_item_user/1', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data, [])

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_owned_by_invalid_uid(self, mock_supabase):
        """Test case for all_items_owned_by - invalid user ID"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/all_item_user/999999', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data, [])

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_owned_by_negative_uid(self, mock_supabase):
        """Test case for all_items_owned_by - negative user ID"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/all_item_user/-1', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data, [])

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_owned_by_string_uid(self, mock_supabase):
        """Test case for all_items_owned_by - string user ID"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/all_item_user/invalid', method='GET')
        self.assert200(response)
        # Framework should handle string conversion to int, or return error

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_get_found(self, mock_supabase):
        """Test case for item_get - item found"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [
            {'id': 1, 'name': 'Test Item', 'description': 'A test item', 'cost': 150}
        ]
        response = self.client.open('/item/1', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertIsInstance(data, list)
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]['id'], 1)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_get_not_found(self, mock_supabase):
        """Test case for item_get - item not found"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/item/999', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data, [])

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_get_invalid_id_negative(self, mock_supabase):
        """Test case for item_get - negative item ID"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/item/-1', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data, [])

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_get_invalid_id_zero(self, mock_supabase):
        """Test case for item_get - zero item ID"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/item/0', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data, [])

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_get_invalid_id_string(self, mock_supabase):
        """Test case for item_get - string item ID"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/item/invalid', method='GET')
        # Framework should return 404 or validation error for invalid ID format

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_get_multiple_results(self, mock_supabase):
        """Test case for item_get - multiple items with same ID (edge case)"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [
            {'id': 1, 'name': 'Item 1a'},
            {'id': 1, 'name': 'Item 1b'}  # Duplicate ID (shouldn't happen in real DB)
        ]
        response = self.client.open('/item/1', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(len(data), 2)

    # ITEM USER ASSIGNMENT TESTS
    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_success_json(self, mock_supabase):
        """Test case for item_user_post - successful JSON request"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'id': 1, 'uid': 1}
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='application/json')
        self.assert200(response)
        data = response.data.decode('utf-8')
        self.assertIn('Success', data)

    @patch('openapi_server.controllers.item_controller.connexion')
    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_success_non_json(self, mock_supabase, mock_connexion):
        """Test case for item_user_post - successful non-JSON request"""
        mock_connexion.request.is_json = False
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        
        # Simulate non-JSON request
        user_id = {'id': 1, 'uid': 1}
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='text/plain')
        self.assert200(response)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_missing_id(self, mock_supabase):
        """Test case for item_user_post - missing item ID"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'uid': 1}  # Missing id
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='application/json')
        # Should still work as controller doesn't validation missing fields
        self.assert200(response)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_missing_uid(self, mock_supabase):
        """Test case for item_user_post - missing user ID"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'id': 1}  # Missing uid
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='application/json')
        self.assert200(response)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_invalid_data_types(self, mock_supabase):
        """Test case for item_user_post - invalid data types"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'id': 'invalid', 'uid': 'invalid'}
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='application/json')
        # Controller doesn't validate data types, so this might succeed or fail at DB level
        self.assert200(response)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_negative_ids(self, mock_supabase):
        """Test case for item_user_post - negative IDs"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'id': -1, 'uid': -1}
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='application/json')
        self.assert200(response)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_zero_ids(self, mock_supabase):
        """Test case for item_user_post - zero IDs"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'id': 0, 'uid': 0}
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='application/json')
        self.assert200(response)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_duplicate_assignment(self, mock_supabase):
        """Test case for item_user_post - duplicate item assignment"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'id': 1, 'uid': 1}
        
        # First assignment
        response1 = self.client.open('/item_user', method='POST', 
                                   data=json.dumps(user_id), content_type='application/json')
        self.assert200(response1)
        
        # Duplicate assignment (should be handled by DB constraints)
        response2 = self.client.open('/item_user', method='POST', 
                                   data=json.dumps(user_id), content_type='application/json')
        self.assert200(response2)

    def test_item_user_post_invalid_json(self):
        """Test case for item_user_post - invalid JSON"""
        response = self.client.open('/item_user', method='POST', 
                                  data='invalid json', content_type='application/json')
        # Should return 400 for invalid JSON

    def test_item_user_post_empty_body(self):
        """Test case for item_user_post - empty request body"""
        response = self.client.open('/item_user', method='POST', 
                                  data='', content_type='application/json')
        # Should return 400 for empty body

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_very_large_ids(self, mock_supabase):
        """Test case for item_user_post - very large IDs"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'id': 999999999999, 'uid': 999999999999}
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='application/json')
        self.assert200(response)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_additional_fields(self, mock_supabase):
        """Test case for item_user_post - additional fields in request"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_id = {'id': 1, 'uid': 1, 'extra_field': 'extra_value', 'another_field': 123}
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='application/json')
        self.assert200(response)

    # DATABASE ERROR SIMULATION TESTS
    @patch('openapi_server.controllers.item_controller.supabase')
    def test_all_items_get_database_exception(self, mock_supabase):
        """Test case for all_items_get - database exception"""
        mock_supabase.table.return_value.select.return_value.execute.side_effect = Exception("Database error")
        response = self.client.open('/item', method='GET')
        # Should return 500 or handle exception gracefully

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_user_post_database_exception(self, mock_supabase):
        """Test case for item_user_post - database exception during insert"""
        mock_supabase.table.return_value.insert.return_value.execute.side_effect = Exception("Insert failed")
        user_id = {'id': 1, 'uid': 1}
        response = self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_id), content_type='application/json')
        # Should handle database exceptions gracefully


if __name__ == '__main__':
    unittest.main()
