import unittest
from unittest.mock import patch, MagicMock
from flask import json
from openapi_server.models.quest_user import QuestUser
from openapi_server.test import BaseTestCase
from datetime import date


class TestQuestController(BaseTestCase):
    """QuestController integration test stubs"""

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_all_quests_done_by(self, mock_supabase):
        """Test case for all_quests_done_by"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{'qid': 1}]
        response = self.client.open('/all_quests_user/{uid}'.format(uid=1), method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))
        self.assertIsInstance(json.loads(response.data), list)

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_all_quests_get(self, mock_supabase):
        """Test case for all_quests_get"""
        mock_supabase.table.return_value.select.return_value.execute.return_value.data = [{'id': 1, 'name': 'Test Quest'}]
        response = self.client.open('/all_quests', method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))
        self.assertIsInstance(json.loads(response.data), list)

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_dailyquest_get(self, mock_supabase):
        """Test case for dailyquest_get"""
        today = date.today().isoformat()
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value.data = [{'id': 1, 'name': 'Daily Quest', 'last_used_d': today}]
        response = self.client.open('/dailyquest/{city}'.format(city=1), method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_quest_user_post(self, mock_supabase):
        """Test case for quest_user_post"""
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = []
        quest_user = {'id': 1, 'uid': 1, 'steps': 10, 'timeInSeconds': 120}
        response = self.client.open(
            '/quest_user',
            method='POST',
            data=json.dumps(quest_user),
            content_type='application/json')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_weeklyquest_get(self, mock_supabase):
        """Test case for weeklyquest_get"""
        today = date.today()
        iso_year, iso_week, _ = today.isocalendar()
        iso_string = f"{iso_year}-W{iso_week:02d}"
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{'id': 1, 'name': 'Weekly Quest', 'last_used_w': iso_string}]
        response = self.client.open('/weeklyquest', method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_activequest_get_found(self, mock_supabase):
        """Test case for activequest_get found"""
        mock_execute_active = MagicMock()
        mock_execute_active.data = [{'qid': 1}]

        mock_execute_quest = MagicMock()
        mock_execute_quest.data = {'id': 1, 'name': 'Active Quest'}

        # This is a bit tricky, we have two different call chains to mock.
        # We can configure the return_value of the chain.
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_execute_active
        mock_supabase.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value = mock_execute_quest

        response = self.client.open('/activequest/{uid}'.format(uid=1), method='GET')
        self.assert200(response, 'Response body is : ' + response.data.decode('utf-8'))

    @patch('openapi_server.controllers.quest_controller.supabase')
    def test_activequest_get_not_found(self, mock_supabase):
        """Test case for activequest_get not found"""
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        response = self.client.open('/activequest/{uid}'.format(uid=1), method='GET')
        self.assert404(response, 'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
