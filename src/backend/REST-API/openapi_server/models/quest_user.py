from openapi_server.models.base_model import Model
from openapi_server import util


class QuestUser(Model):
    """Model for assigning a quest to a user, including steps and duration."""

    def __init__(self, uid=None, id=None, steps=None, timeInSeconds=None):
        self.openapi_types = {
            'uid': int,
            'id': int,
            'steps': int,
            'timeInSeconds': int
        }

        self.attribute_map = {
            'uid': 'uid',
            'id': 'id',
            'steps': 'steps',
            'timeInSeconds': 'timeInSeconds'
        }

        self._uid = uid
        self._id = id
        self._steps = steps
        self._timeInSeconds = timeInSeconds

    @classmethod
    def from_dict(cls, dikt) -> 'QuestUser':
        return util.deserialize_model(dikt, cls)

    @property
    def uid(self) -> int:
        return self._uid

    @uid.setter
    def uid(self, uid: int):
        if uid is None:
            raise ValueError("Ungültiger Wert für `uid`, darf nicht `None` sein")
        if uid < 1:
            raise ValueError("Ungültiger Wert für `uid`, muss mindestens 1 sein")
        self._uid = uid

    @property
    def id(self) -> int:
        return self._id

    @id.setter
    def id(self, id: int):
        if id is None:
            raise ValueError("Ungültiger Wert für `id`, darf nicht `None` sein")
        if id < 1:
            raise ValueError("Ungültiger Wert für `id`, muss mindestens 1 sein")

        self._id = id

    @property
    def steps(self) -> int:
        return self._steps

    @steps.setter
    def steps(self, steps: int):
        if steps is None or steps < 0:
            raise ValueError("Ungültiger Wert für `steps`, muss mindestens 0 sein")
        self._steps = steps

    @property
    def timeInSeconds(self) -> int:
        return self._timeInSeconds

    @timeInSeconds.setter
    def timeInSeconds(self, timeInSeconds: int):
        if timeInSeconds is None or timeInSeconds < 0:
            timeInSeconds = 0
        self._timeInSeconds = timeInSeconds
