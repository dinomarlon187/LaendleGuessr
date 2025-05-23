import unittest

from flask import json

from openapi_server.models.user_id import UserId  # noqa: E501
from openapi_server.test import BaseTestCase


class TestQuestController(BaseTestCase):
    """QuestController integration test stubs"""

    def test_all_quests_done_by(self):
        """Test case for all_quests_done_by

        Alle gemachten Quests eines users bekommen
        """
        headers = { 
        }
        response = self.client.open(
            '/all_quests_user/{uid}'.format(uid=56),
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_all_quests_get(self):
        """Test case for all_quests_get

        Alle Quests bekommen
        """
        headers = { 
        }
        response = self.client.open(
            '/all_quests',
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_dailyquest_get(self):
        """Test case for dailyquest_get

        Derzeitige DailyQuest einer Stadt
        """
        headers = { 
        }
        response = self.client.open(
            '/dailyquest/{city}'.format(city=56),
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_quest_user_post(self):
        """Test case for quest_user_post

        Einem User eine Quest als gemacht zuschreiben
        """
        user_id = openapi_server.UserId()
        headers = { 
            'Content-Type': 'application/json',
        }
        response = self.client.open(
            '/quest_user',
            method='POST',
            headers=headers,
            data=json.dumps(user_id),
            content_type='application/json')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_weeklyquest_get(self):
        """Test case for weeklyquest_get

        Derzeitige globale WeeklyQuest
        """
        headers = { 
        }
        response = self.client.open(
            '/weeklyquest',
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
