import unittest
from unittest.mock import patch, MagicMock
from flask import json
from openapi_server.test import BaseTestCase

class TestControllerEdgeCases(BaseTestCase):
    """Tests for critical edge cases and integration scenarios across all controllers"""

    # CROSS-CONTROLLER INTEGRATION TESTS
    
    @patch('openapi_server.controllers.user_controller.supabase')
    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_user_quest_integration(self, mock_quest_supabase, mock_user_supabase):
        """Test integration between user and quest controllers"""
        # Create user first
        mock_user_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_user_supabase.table.return_value.insert.return_value.execute.return_value.data = [{'uid': 1}]
        
        user = {'username': 'testuser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        user_response = self.client.open('/user', method='POST', 
                                       data=json.dumps(user), content_type='application/json')
        
        # Then assign quest to user
        mock_quest_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        quest_user = {'id': 1, 'uid': 1, 'steps': 100, 'timeInSeconds': 300}
        quest_response = self.client.open('/quest_user', method='POST', 
                                        data=json.dumps(quest_user), content_type='application/json')
        
        # Both operations should succeed
        self.assertIn(user_response.status_code, [200, 201])
        self.assert200(quest_response)

    @patch('openapi_server.controllers.user_controller.supabase')
    @patch('openapi_server.controllers.item_controller.supabase')
    def test_user_item_integration(self, mock_item_supabase, mock_user_supabase):
        """Test integration between user and item controllers"""
        # Create user first
        mock_user_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_user_supabase.table.return_value.insert.return_value.execute.return_value.data = [{'uid': 1}]
        
        user = {'username': 'testuser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        user_response = self.client.open('/user', method='POST', 
                                       data=json.dumps(user), content_type='application/json')
        
        # Then assign item to user
        mock_item_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        user_item = {'id': 1, 'uid': 1}
        item_response = self.client.open('/item_user', method='POST', 
                                       data=json.dumps(user_item), content_type='application/json')
        
        # Both operations should succeed
        self.assertIn(user_response.status_code, [200, 201])
        self.assert200(item_response)

    # CONCURRENCY AND RACE CONDITION TESTS
    
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_concurrent_user_creation(self, mock_supabase):
        """Test concurrent user creation with same username"""
        # First user creation should succeed
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = [{'uid': 1}]
        
        user = {'username': 'testuser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        response1 = self.client.open('/user', method='POST', 
                                   data=json.dumps(user), content_type='application/json')
        
        # Second user creation with same username should fail
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{'uid': 1}]
        response2 = self.client.open('/user', method='POST', 
                                   data=json.dumps(user), content_type='application/json')
        
        self.assertIn(response1.status_code, [200, 201])
        self.assertStatus(response2, 409)

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_active_quest_race_condition(self, mock_supabase):
        """Test race condition in active quest assignment"""
        # Simulate concurrent active quest assignments
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        
        quest_data = {'uid': 1, 'qid': 1}
        
        # Multiple requests for same user
        response1 = self.client.open('/activequest', method='POST', 
                                   data=json.dumps(quest_data), content_type='application/json')
        response2 = self.client.open('/activequest', method='POST', 
                                   data=json.dumps(quest_data), content_type='application/json')
        
        # Both might succeed at controller level, but DB should handle uniqueness
        self.assert200(response1)
        self.assert200(response2)

    # BOUNDARY VALUE TESTS
    
    def test_user_id_boundaries(self):
        """Test boundary values for user IDs"""
        # Test with various user ID boundary values
        test_ids = [0, 1, -1, 2147483647, -2147483648, 9223372036854775807]
        
        for uid in test_ids:
            with self.subTest(uid=uid):
                response = self.client.open(f'/all_item_user/{uid}', method='GET')
                # Should handle all ID values gracefully (return empty or error)
                self.assertIn(response.status_code, [200, 400, 404])

    def test_item_id_boundaries(self):
        """Test boundary values for item IDs"""
        test_ids = [0, 1, -1, 2147483647, -2147483648]
        
        for item_id in test_ids:
            with self.subTest(item_id=item_id):
                response = self.client.open(f'/item/{item_id}', method='GET')
                self.assertIn(response.status_code, [200, 400, 404])

    # MALFORMED REQUEST TESTS
    
    def test_malformed_json_requests(self):
        """Test various malformed JSON requests"""
        malformed_jsons = [
            '{"incomplete": ',
            '{"invalid": value}',
            '{duplicate": "key", "duplicate": "key2"}',
            '{"nested": {"unclosed": }',
            '{"unicode": "\u0000"}',
            '{"very_long_key_' + 'x' * 10000 + '": "value"}',
            '{"control_chars": "\n\r\t"}',
        ]
        
        endpoints = ['/user', '/quest_user', '/item_user']
        
        for endpoint in endpoints:
            for malformed_json in malformed_jsons:
                with self.subTest(endpoint=endpoint, json=malformed_json[:50]):
                    response = self.client.open(endpoint, method='POST', 
                                              data=malformed_json, content_type='application/json')
                    # Should handle malformed JSON gracefully
                    self.assertIn(response.status_code, [400, 422, 500])

    def test_extremely_large_requests(self):
        """Test handling of extremely large request bodies"""
        # Very large username
        large_user = {
            'username': 'x' * 10000,
            'password': 'password123',
            'city': 1,
            'admin': False,
            'coins': 0
        }
        
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(large_user), content_type='application/json')
        # Should handle large requests appropriately
        self.assertIn(response.status_code, [400, 413, 422])

    def test_null_and_undefined_values(self):
        """Test handling of null and undefined values"""
        test_users = [
            {'username': None, 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0},
            {'username': 'testuser', 'password': None, 'city': 1, 'admin': False, 'coins': 0},
            {'username': 'testuser', 'password': 'password123', 'city': None, 'admin': False, 'coins': 0},
            {'username': 'testuser', 'password': 'password123', 'city': 1, 'admin': None, 'coins': 0},
        ]
        
        for user in test_users:
            with self.subTest(user=user):
                response = self.client.open('/user', method='POST', 
                                          data=json.dumps(user), content_type='application/json')
                # Should validate required fields
                self.assertIn(response.status_code, [400, 422])

    # SPECIAL CHARACTER TESTS
    
    def test_special_characters_in_usernames(self):
        """Test usernames with special characters"""
        special_usernames = [
            'user@domain.com',
            'user-name_123',
            'üser_nämé',
            '用户名',
            'user\nname',
            'user\tname',
            'user name',
            '<script>alert("xss")</script>',
            "'; DROP TABLE users; --",
            '../../etc/passwd',
        ]
        
        for username in special_usernames:
            with self.subTest(username=username):
                user = {
                    'username': username,
                    'password': 'password123',
                    'city': 1,
                    'admin': False,
                    'coins': 0
                }
                response = self.client.open('/user', method='POST', 
                                          data=json.dumps(user), content_type='application/json')
                # Should handle special characters appropriately
                self.assertIn(response.status_code, [200, 201, 400, 422])

    # ENCODING TESTS
    
    def test_different_encodings(self):
        """Test different character encodings"""
        # Test UTF-8 with various languages
        usernames = [
            'English123',
            'Español123',
            'Français123', 
            'Deutsch123',
            '中文用户',
            'العربية',
            'русский',
            '日本語',
        ]
        
        for username in usernames:
            with self.subTest(username=username):
                user = {
                    'username': username,
                    'password': 'password123',
                    'city': 1,
                    'admin': False,
                    'coins': 0
                }
                response = self.client.open('/user', method='POST', 
                                          data=json.dumps(user, ensure_ascii=False), 
                                          content_type='application/json; charset=utf-8')
                # Should handle UTF-8 properly
                self.assertIn(response.status_code, [200, 201, 400, 409, 422])

    # PERFORMANCE EDGE CASES
    
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_large_dataset_response(self, mock_supabase):
        """Test handling of large dataset responses"""
        # Simulate large number of users
        large_dataset = [{'uid': i, 'username': f'user{i}'} for i in range(10000)]
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = large_dataset
        
        response = self.client.open('/user', method='GET')
        self.assert200(response)
        
        # Response should contain all users but may be paginated in real implementation
        data = json.loads(response.data)
        self.assertIsInstance(data, list)

    # SECURITY EDGE CASES
    
    def test_password_edge_cases(self):
        """Test various password edge cases"""
        password_tests = [
            ('', 400),  # Empty password
            ('1234567', 400),  # Too short
            ('password with spaces', 400),  # Contains spaces
            ('a' * 1000, None),  # Very long password
            ('password123', None),  # Valid password
            ('пароль123', None),  # Non-ASCII password
            ('pass\x00word', None),  # Null byte
        ]
        
        for password, expected_status in password_tests:
            with self.subTest(password=password[:20]):
                user = {
                    'username': f'user_{len(password)}',
                    'password': password,
                    'city': 1,
                    'admin': False,
                    'coins': 0
                }
                response = self.client.open('/user', method='POST', 
                                          data=json.dumps(user), content_type='application/json')
                
                if expected_status:
                    self.assertEqual(response.status_code, expected_status)
                else:
                    self.assertIn(response.status_code, [200, 201, 400, 422])

    # CONTENT TYPE TESTS
    
    def test_unsupported_content_types(self):
        """Test various unsupported content types"""
        content_types = [
            'application/xml',
            'text/plain',
            'application/x-www-form-urlencoded',
            'multipart/form-data',
            'application/octet-stream',
            'image/jpeg',
            'text/html',
        ]
        
        user_data = {'username': 'testuser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        
        for content_type in content_types:
            with self.subTest(content_type=content_type):
                response = self.client.open('/user', method='POST', 
                                          data=json.dumps(user_data), content_type=content_type)
                # Should handle unsupported content types appropriately
                self.assertIn(response.status_code, [400, 415, 422])


if __name__ == '__main__':
    unittest.main()
