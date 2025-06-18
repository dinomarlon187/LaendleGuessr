from openapi_server.logger import logger
import sys

if sys.version_info < (3, 7):
    import typing

    def is_generic(klass):
        """ Determine whether klass is a generic class """
        logger.debug(f"typing_utils.py: is_generic() (Python <3.7) aufgerufen für {klass}")
        result = type(klass) == typing.GenericMeta
        logger.debug(f"typing_utils.py: is_generic() Ergebnis: {result}")
        return result

    def is_dict(klass):
        """ Determine whether klass is a Dict """
        logger.debug(f"typing_utils.py: is_dict() (Python <3.7) aufgerufen für {klass}")
        result = klass.__extra__ == dict
        logger.debug(f"typing_utils.py: is_dict() Ergebnis: {result}")
        return result

    def is_list(klass):
        """ Determine whether klass is a List """
        logger.debug(f"typing_utils.py: is_list() (Python <3.7) aufgerufen für {klass}")
        result = klass.__extra__ == list
        logger.debug(f"typing_utils.py: is_list() Ergebnis: {result}")
        return result

else:

    def is_generic(klass):
        """ Determine whether klass is a generic class """
        logger.debug(f"typing_utils.py: is_generic() aufgerufen für {klass}")
        result = hasattr(klass, '__origin__')
        logger.debug(f"typing_utils.py: is_generic() Ergebnis: {result}")
        return result

    def is_dict(klass):
        """ Determine whether klass is a Dict """
        logger.debug(f"typing_utils.py: is_dict() aufgerufen für {klass}")
        result = klass.__origin__ == dict
        logger.debug(f"typing_utils.py: is_dict() Ergebnis: {result}")
        return result

    def is_list(klass):
        """ Determine whether klass is a List """
        logger.debug(f"typing_utils.py: is_list() aufgerufen für {klass}")
        result = klass.__origin__ == list
        logger.debug(f"typing_utils.py: is_list() Ergebnis: {result}")
        return result
