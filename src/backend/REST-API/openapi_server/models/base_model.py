import pprint

import typing

from openapi_server import util
from openapi_server.logger import logger

T = typing.TypeVar('T')


class Model:
    # openapiTypes: The key is attribute name and the
    # value is attribute type.
    openapi_types: typing.Dict[str, type] = {}

    # attributeMap: The key is attribute name and the
    # value is json key in definition.
    attribute_map: typing.Dict[str, str] = {}

    @classmethod
    def from_dict(cls: typing.Type[T], dikt) -> T:
        """Returns the dict as a model"""
        logger.debug(f"models/base_model.py: Model.from_dict() aufgerufen für Klasse {cls.__name__} mit: {dikt}")
        model = util.deserialize_model(dikt, cls)
        logger.debug(f"models/base_model.py: Model {cls.__name__} erfolgreich aus Dictionary erstellt")
        return model

    def to_dict(self):
        """Returns the model properties as a dict

        :rtype: dict
        """
        logger.debug(f"models/base_model.py: to_dict() aufgerufen für {self.__class__.__name__}")
        result = {}

        for attr in self.openapi_types:
            value = getattr(self, attr)
            if isinstance(value, list):
                logger.debug(f"models/base_model.py: Konvertiere List-Attribut {attr}")
                result[attr] = list(map(
                    lambda x: x.to_dict() if hasattr(x, "to_dict") else x,
                    value
                ))
            elif hasattr(value, "to_dict"):
                logger.debug(f"models/base_model.py: Konvertiere Model-Attribut {attr}")
                result[attr] = value.to_dict()
            elif isinstance(value, dict):
                logger.debug(f"models/base_model.py: Konvertiere Dict-Attribut {attr}")
                result[attr] = dict(map(
                    lambda item: (item[0], item[1].to_dict())
                    if hasattr(item[1], "to_dict") else item,
                    value.items()
                ))
            else:
                result[attr] = value

        return result

    def to_str(self):
        """Returns the string representation of the model

        :rtype: str
        """
        return pprint.pformat(self.to_dict())

    def __repr__(self):
        """For `print` and `pprint`"""
        return self.to_str()

    def __eq__(self, other):
        """Returns true if both objects are equal"""
        return self.__dict__ == other.__dict__

    def __ne__(self, other):
        """Returns true if both objects are not equal"""
        return not self == other
