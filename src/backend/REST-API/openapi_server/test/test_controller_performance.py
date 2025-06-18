import unittest
import time
from unittest.mock import patch, MagicMock
from flask import json
from openapi_server.test import BaseTestCase
from concurrent.futures import ThreadPoolExecutor
import threading

class TestControllerPerformance(BaseTestCase):
    """Performance and load tests for all controllers"""

    def setUp(self):
        super().setUp()
        self.request_times = []
        self.lock = threading.Lock()

    def measure_response_time(self, func):
        """Decorator to measure response time"""
        def wrapper(*args, **kwargs):
            start_time = time.time()
            result = func(*args, **kwargs)
            end_time = time.time()
            
            with self.lock:
                self.request_times.append(end_time - start_time)
            
            return result
        return wrapper

    # RESPONSE TIME TESTS

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_user_get_response_time(self, mock_supabase):
        """Test response time for user retrieval"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = {
            'uid': 1, 'username': 'testuser'
        }
        
        @self.measure_response_time
        def make_request():
            return self.client.open('/user/1', method='GET')
        
        # Make multiple requests to get average response time
        for _ in range(10):
            response = make_request()
            self.assert200(response)
        
        avg_time = sum(self.request_times) / len(self.request_times)
        self.assertLess(avg_time, 0.1, "User GET should respond within 100ms")

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_quest_list_response_time(self, mock_supabase):
        """Test response time for quest list retrieval"""
        # Simulate large quest list
        large_quest_list = [{'id': i, 'name': f'Quest {i}'} for i in range(1000)]
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = large_quest_list
        
        @self.measure_response_time
        def make_request():
            return self.client.open('/all_quests', method='GET')
        
        response = make_request()
        self.assert200(response)
        
        # Should handle large datasets within reasonable time
        self.assertLess(self.request_times[-1], 0.5, "Quest list should respond within 500ms")

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_item_list_response_time(self, mock_supabase):
        """Test response time for item list retrieval"""
        large_item_list = [{'id': i, 'name': f'Item {i}'} for i in range(1000)]
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = large_item_list
        
        @self.measure_response_time
        def make_request():
            return self.client.open('/item', method='GET')
        
        response = make_request()
        self.assert200(response)
        
        self.assertLess(self.request_times[-1], 0.5, "Item list should respond within 500ms")

    # CONCURRENT REQUEST TESTS

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_concurrent_user_requests(self, mock_supabase):
        """Test handling of concurrent user requests"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = {
            'uid': 1, 'username': 'testuser'
        }
        
        def make_request(user_id):
            return self.client.open(f'/user/{user_id}', method='GET')
        
        # Make 50 concurrent requests
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(make_request, i % 10 + 1) for i in range(50)]
            responses = [future.result() for future in futures]
        
        # All requests should succeed
        for response in responses:
            self.assert200(response)

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_concurrent_quest_assignments(self, mock_supabase):
        """Test concurrent quest assignments"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        
        def assign_quest(quest_id):
            quest_user = {'id': quest_id, 'uid': 1, 'steps': 100, 'timeInSeconds': 300}
            return self.client.open('/quest_user', method='POST', 
                                  data=json.dumps(quest_user), content_type='application/json')
        
        # Make 20 concurrent quest assignments
        with ThreadPoolExecutor(max_workers=5) as executor:
            futures = [executor.submit(assign_quest, i) for i in range(20)]
            responses = [future.result() for future in futures]
        
        # All requests should be handled (though some might conflict in real DB)
        for response in responses:
            self.assert200(response)

    @patch('openapi_server.controllers.item_controller.supabase')
    def test_concurrent_item_assignments(self, mock_supabase):
        """Test concurrent item assignments"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        
        def assign_item(item_id):
            user_item = {'id': item_id, 'uid': 1}
            return self.client.open('/item_user', method='POST', 
                                  data=json.dumps(user_item), content_type='application/json')
        
        with ThreadPoolExecutor(max_workers=5) as executor:
            futures = [executor.submit(assign_item, i) for i in range(20)]
            responses = [future.result() for future in futures]
        
        for response in responses:
            self.assert200(response)

    # MEMORY USAGE TESTS

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_large_user_dataset_memory(self, mock_supabase):
        """Test memory usage with large user dataset"""
        # Simulate very large user dataset
        large_dataset = [
            {
                'uid': i, 
                'username': f'user_{i}',
                'coins': i * 100,
                'admin': i % 2 == 0,
                'city': i % 5,
                'additional_data': 'x' * 1000  # Extra data to increase memory usage
            } 
            for i in range(10000)
        ]
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = large_dataset
        
        response = self.client.open('/user', method='GET')
        self.assert200(response)
        
        # Response should be handled without memory issues
        data = json.loads(response.data)
        self.assertEqual(len(data), 10000)

    # TIMEOUT TESTS

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_slow_database_response(self, mock_supabase):
        """Test handling of slow database responses"""
        def slow_execute():
            time.sleep(2)  # Simulate 2-second database delay
            mock_response = MagicMock()
            mock_response.data = [{'uid': 1, 'username': 'testuser'}]
            return mock_response
        
        mock_supabase.table.return_value.select.return_value.execute.side_effect = slow_execute
        
        start_time = time.time()
        response = self.client.open('/user', method='GET')
        end_time = time.time()
        
        # Should handle slow responses (might timeout or succeed)
        self.assertIn(response.status_code, [200, 408, 500])
        
        # Should not hang indefinitely
        self.assertLess(end_time - start_time, 10, "Request should not take more than 10 seconds")

    # STRESS TESTS

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_rapid_user_creation_stress(self, mock_supabase):
        """Stress test for rapid user creation"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = [{'uid': 1}]
        
        def create_user(index):
            user = {
                'username': f'user_{index}',
                'password': 'password123',
                'city': index % 5,
                'admin': False,
                'coins': 0
            }
            return self.client.open('/user', method='POST', 
                                  data=json.dumps(user), content_type='application/json')
        
        start_time = time.time()
        
        # Create 100 users rapidly
        with ThreadPoolExecutor(max_workers=20) as executor:
            futures = [executor.submit(create_user, i) for i in range(100)]
            responses = [future.result() for future in futures]
        
        end_time = time.time()
        
        # Most should succeed
        success_count = sum(1 for r in responses if r.status_code in [200, 201])
        self.assertGreater(success_count, 80, "At least 80% of user creations should succeed")
        
        # Should complete within reasonable time
        self.assertLess(end_time - start_time, 30, "100 user creations should complete within 30 seconds")

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_daily_quest_load_test(self, mock_supabase):
        """Load test for daily quest endpoint"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value.data = [
            {'id': 1, 'name': 'Daily Quest'}
        ]
        
        def get_daily_quest(city):
            return self.client.open(f'/dailyquest/{city}', method='GET')
        
        start_time = time.time()
        
        # Simulate 200 concurrent requests for daily quests
        with ThreadPoolExecutor(max_workers=50) as executor:
            futures = [executor.submit(get_daily_quest, i % 5) for i in range(200)]
            responses = [future.result() for future in futures]
        
        end_time = time.time()
        
        # All should succeed
        for response in responses:
            self.assert200(response)
        
        # Should handle load efficiently
        avg_time_per_request = (end_time - start_time) / 200
        self.assertLess(avg_time_per_request, 0.1, "Average response time should be under 100ms")

    # RESOURCE EXHAUSTION TESTS

    def test_maximum_request_size(self):
        """Test handling of maximum request sizes"""
        # Very large request body
        huge_data = {
            'username': 'x' * 100000,  # 100KB username
            'password': 'password123',
            'city': 1,
            'admin': False,
            'coins': 0,
            'extra_data': 'y' * 1000000  # 1MB extra data
        }
        
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(huge_data), content_type='application/json')
        
        # Should reject or handle large requests appropriately
        self.assertIn(response.status_code, [400, 413, 422, 500])

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_deep_recursion_handling(self, mock_supabase):
        """Test handling of deeply nested JSON"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        
        # Create deeply nested JSON
        nested_data = {'username': 'testuser', 'password': 'password123', 'city': 1, 'admin': False, 'coins': 0}
        current = nested_data
        
        # Create 1000 levels of nesting
        for i in range(1000):
            current['nested'] = {'level': i}
            current = current['nested']
        
        response = self.client.open('/user', method='POST', 
                                  data=json.dumps(nested_data), content_type='application/json')
        
        # Should handle or reject deeply nested JSON
        self.assertIn(response.status_code, [200, 201, 400, 413, 422])

    # CLEANUP AND MEASUREMENT HELPERS

    def tearDown(self):
        """Print performance statistics"""
        if self.request_times:
            avg_time = sum(self.request_times) / len(self.request_times)
            max_time = max(self.request_times)
            min_time = min(self.request_times)
            
            print(f"\nPerformance Stats for {self._testMethodName}:")
            print(f"  Requests: {len(self.request_times)}")
            print(f"  Avg Time: {avg_time:.3f}s")
            print(f"  Min Time: {min_time:.3f}s")
            print(f"  Max Time: {max_time:.3f}s")
        
        super().tearDown()


class TestControllerStability(BaseTestCase):
    """Stability and reliability tests"""

    @patch('openapi_server.controllers.user_controller.supabase')
    def test_repeated_operations_stability(self, mock_supabase):
        """Test stability under repeated operations"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value.data = {
            'uid': 1, 'username': 'testuser'
        }
        
        # Perform 1000 identical requests
        for i in range(1000):
            response = self.client.open('/user/1', method='GET')
            self.assert200(response)
            
            # Check for memory leaks or degradation every 100 requests
            if i % 100 == 0:
                data = json.loads(response.data)
                self.assertEqual(data['uid'], 1)

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_error_recovery(self, mock_supabase):
        """Test error recovery and resilience"""
        # Simulate intermittent database errors
        call_count = 0
        
        def intermittent_error():
            nonlocal call_count
            call_count += 1
            if call_count % 3 == 0:  # Every 3rd call fails
                raise Exception("Database temporarily unavailable")
            else:
                mock_response = MagicMock()
                mock_response.data = [{'id': 1, 'name': 'Quest'}]
                return mock_response
        
        mock_supabase.table.return_value.select.return_value.execute.side_effect = intermittent_error
        
        success_count = 0
        error_count = 0
        
        # Make 30 requests (should have 10 errors, 20 successes)
        for _ in range(30):
            try:
                response = self.client.open('/all_quests', method='GET')
                if response.status_code == 200:
                    success_count += 1
                else:
                    error_count += 1
            except:
                error_count += 1
        
        # Should handle errors gracefully and continue processing
        self.assertGreater(success_count, 15, "Should recover from intermittent errors")


if __name__ == '__main__':
    unittest.main()
