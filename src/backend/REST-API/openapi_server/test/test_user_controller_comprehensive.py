import unittest
from unittest.mock import patch, MagicMock
from flask import json
from openapi_server.models.user import User
from openapi_server.test import BaseTestCase

class TestUserControllerComprehensive(BaseTestCase):
    """Comprehensive UserController unit tests covering all edge cases"""

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_all_users_get_success(self, mock_supabase):
        """Test case for all_users_get - successful response"""
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = [
            {'uid': 1, 'username': 'user1', 'coins': 100},
            {'uid': 2, 'username': 'user2', 'coins': 200}
        ]
        response = self.client.open('/user', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertIsInstance(data, list)
        self.assertEqual(len(data), 2)

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_all_users_get_empty(self, mock_supabase):
        """Test case for all_users_get - empty result"""
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = []
        response = self.client.open('/user', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data, [])

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_get_found(self, mock_supabase):
        """Test case for user_get - user found"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = {
            'uid': 1, 'username': 'testuser', 'coins': 100, 'admin': False, 'city': 1
        }
        response = self.client.open('/user/1', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data['uid'], 1)
        self.assertEqual(data['username'], 'testuser')

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_get_not_found(self, mock_supabase):
        """Test case for user_get - user not found"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = None
        response = self.client.open('/user/999', method='GET')
        self.assert404(response)
        data = json.loads(response.data)
        self.assertIn('nachricht', data)

    # USER LOGIN TESTS
    @patch('openapi_server.controllers.user_controller.bcrypt')
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_login_success(self, mock_supabase, mock_bcrypt):
        """Test case for user_login - successful login"""
        user_data = {
            'uid': 1, 'username': 'testuser', 'password': 'hashed_password', 
            'coins': 100, 'admin': False, 'city': 1
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = user_data
        mock_bcrypt.checkpw.return_value = True
        
        credentials = {'username': 'testuser', 'password': 'password123'}
        response = self.client.open('/user/login', method='POST', 
                                  data=json.dumps(credentials), content_type='application/json')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data['uid'], 1)
        self.assertEqual(data['username'], 'testuser')

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_login_user_not_found(self, mock_supabase):
        """Test case for user_login - user not found"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = None
        credentials = {'username': 'nonexistent', 'password': 'password123'}
        response = self.client.open('/user/login', method='POST', 
                                  data=json.dumps(credentials), content_type='application/json')
        self.assert401(response)

    @patch('openapi_server.controllers.user_controller.bcrypt')
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_login_wrong_password(self, mock_supabase, mock_bcrypt):
        """Test case for user_login - wrong password"""
        user_data = {'uid': 1, 'username': 'testuser', 'password': 'hashed_password'}
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = user_data
        mock_bcrypt.checkpw.return_value = False
        
        credentials = {'username': 'testuser', 'password': 'wrongpassword'}
        response = self.client.open('/user/login', method='POST', 
                                  data=json.dumps(credentials), content_type='application/json')
        self.assert401(response)

    def test_user_login_non_json(self):
        """Test case for user_login - non-JSON request"""
        response = self.client.open('/user/login', method='POST', 
                                  data='not json', content_type='text/plain')
        self.assert400(response)

    def test_user_login_missing_username(self):
        """Test case for user_login - missing username"""
        credentials = {'password': 'password123'}
        response = self.client.open('/user/login', method='POST', 
                                  data=json.dumps(credentials), content_type='application/json')
        self.assert400(response)

    def test_user_login_missing_password(self):
        """Test case for user_login - missing password"""
        credentials = {'username': 'testuser'}
        response = self.client.open('/user/login', method='POST', 
                                  data=json.dumps(credentials), content_type='application/json')
        self.assert400(response)

    def test_user_login_empty_credentials(self):
        """Test case for user_login - empty credentials"""
        credentials = {'username': '', 'password': ''}
        response = self.client.open('/user/login', method='POST', 
                                  data=json.dumps(credentials), content_type='application/json')
        self.assert400(response)

    # USER CREATION TESTS
    @patch('openapi_server.controllers.user_controller.bcrypt')
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_post_success(self, mock_supabase, mock_bcrypt):
        """Test case for user_post - successful creation"""
        # Mock username check (no existing user)
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        # Mock successful insert
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = [{'uid': 1}]
        mock_bcrypt.hashpw.return_value.decode.return_value = 'hashed_password'
        
        user = {'username': 'newuser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assertStatus(response, 201)

    def test_user_post_non_json(self):
        """Test case for user_post - non-JSON request"""
        response = self.client.open('/user', method='POST', 
                                  data='not json', content_type='text/plain')
        self.assert400(response)

    def test_user_post_missing_username(self):
        """Test case for user_post - missing username"""
        user = {'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assert400(response)

    def test_user_post_missing_password(self):
        """Test case for user_post - missing password"""
        user = {'username': 'newuser', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assert400(response)

    def test_user_post_password_too_short(self):
        """Test case for user_post - password too short"""
        user = {'username': 'newuser', 'password': 'short', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assert400(response)

    def test_user_post_password_with_spaces(self):
        """Test case for user_post - password with spaces"""
        user = {'username': 'newuser', 'password': 'pass word123', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assert400(response)

    def test_user_post_invalid_city_negative(self):
        """Test case for user_post - invalid city (negative)"""
        user = {'username': 'newuser', 'password': 'password123', 'city': -1, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assert400(response)

    def test_user_post_invalid_city_too_high(self):
        """Test case for user_post - invalid city (too high)"""
        user = {'username': 'newuser', 'password': 'password123', 'city': 5, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assert400(response)

    def test_user_post_invalid_city_string(self):
        """Test case for user_post - invalid city (string)"""
        user = {'username': 'newuser', 'password': 'password123', 'city': 'invalid', 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assert400(response)

    def test_user_post_invalid_admin_string(self):
        """Test case for user_post - invalid admin value (string)"""
        user = {'username': 'newuser', 'password': 'password123', 'city': 1, 'admin': 'invalid', 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assert400(response)

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_post_username_exists(self, mock_supabase):
        """Test case for user_post - username already exists"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{'uid': 1}]
        user = {'username': 'existinguser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assertStatus(response, 409)

    @patch('openapi_server.controllers.user_controller.bcrypt')
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_post_database_error(self, mock_supabase, mock_bcrypt):
        """Test case for user_post - database error during creation"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = None
        mock_bcrypt.hashpw.return_value.decode.return_value = 'hashed_password'
        
        user = {'username': 'newuser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        self.assert500(response)

    # USER UPDATE TESTS
    @patch('openapi_server.controllers.user_controller.bcrypt')
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_update_success(self, mock_supabase, mock_bcrypt):
        """Test case for user_update - successful update"""
        # Mock username check (no conflict)
        mock_supabase.table.return_value.select.return_value.eq.return_value.neq.return_value.execute.return_value.data = []
        # Mock successful update
        mock_supabase.table.return_value.update.return_value.eq.return_value.execute.return_value.data = [{'uid': 1}]
        mock_bcrypt.hashpw.return_value.decode.return_value = 'new_hashed_password'
        
        user_data = {'username': 'updateduser', 'password': 'newpassword123', 'coins': 500}
        response = self.client.open('/user/1', method='PUT', 
                                  data=json.dumps(user_data), content_type='application/json')
        self.assert200(response)

    def test_user_update_non_json(self):
        """Test case for user_update - non-JSON request"""
        response = self.client.open('/user/1', method='PUT', 
                                  data='not json', content_type='text/plain')
        self.assert400(response)

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_update_username_conflict(self, mock_supabase):
        """Test case for user_update - username already exists"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.neq.return_value.execute.return_value.data = [{'uid': 2}]
        
        user_data = {'username': 'existinguser'}
        response = self.client.open('/user/1', method='PUT', 
                                  data=json.dumps(user_data), content_type='application/json')
        self.assertStatus(response, 409)

    def test_user_update_password_too_short(self):
        """Test case for user_update - password too short"""
        user_data = {'password': 'short'}
        response = self.client.open('/user/1', method='PUT', 
                                  data=json.dumps(user_data), content_type='application/json')
        self.assert400(response)

    def test_user_update_password_with_spaces(self):
        """Test case for user_update - password with spaces"""
        user_data = {'password': 'pass word123'}
        response = self.client.open('/user/1', method='PUT', 
                                  data=json.dumps(user_data), content_type='application/json')
        self.assert400(response)

    def test_user_update_invalid_city(self):
        """Test case for user_update - invalid city"""
        user_data = {'city': 10}
        response = self.client.open('/user/1', method='PUT', 
                                  data=json.dumps(user_data), content_type='application/json')
        self.assert400(response)

    def test_user_update_invalid_admin(self):
        """Test case for user_update - invalid admin value"""
        user_data = {'admin': 'invalid'}
        response = self.client.open('/user/1', method='PUT', 
                                  data=json.dumps(user_data), content_type='application/json')
        self.assert400(response)

    def test_user_update_no_valid_fields(self):
        """Test case for user_update - no valid fields to update"""
        user_data = {}
        response = self.client.open('/user/1', method='PUT', 
                                  data=json.dumps(user_data), content_type='application/json')
        self.assert400(response)

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_update_user_not_found(self, mock_supabase):
        """Test case for user_update - user not found"""
        mock_supabase.table.return_value.update.return_value.eq.return_value.execute.return_value.data = None
        
        user_data = {'coins': 100}
        response = self.client.open('/user/999', method='PUT', 
                                  data=json.dumps(user_data), content_type='application/json')
        self.assert404(response)

    # GET ALL TIME STATS TESTS
    @patch('openapi_server.controllers.user_controller.supabase')
    def test_get_all_time_stats_success(self, mock_supabase):
        """Test case for get_all_time_stats - with data"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [
            {'timeInSeconds': 120, 'steps': 500},
            {'timeInSeconds': 180, 'steps': 750},
            {'timeInSeconds': 90, 'steps': 300}
        ]
        
        response = self.client.open('/user/1/stats', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data['timeInSeconds'], 390)  # 120 + 180 + 90
        self.assertEqual(data['steps'], 1550)  # 500 + 750 + 300

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_get_all_time_stats_no_data(self, mock_supabase):
        """Test case for get_all_time_stats - no data"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        
        response = self.client.open('/user/1/stats', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data['timeInSeconds'], 0)
        self.assertEqual(data['steps'], 0)

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_get_all_time_stats_missing_fields(self, mock_supabase):
        """Test case for get_all_time_stats - missing fields in data"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [
            {'timeInSeconds': 120},  # missing steps
            {'steps': 500},  # missing timeInSeconds
            {}  # missing both
        ]
        
        response = self.client.open('/user/1/stats', method='GET')
        self.assert200(response)
        data = json.loads(response.data)
        self.assertEqual(data['timeInSeconds'], 120)
        self.assertEqual(data['steps'], 500)


if __name__ == '__main__':
    unittest.main()
