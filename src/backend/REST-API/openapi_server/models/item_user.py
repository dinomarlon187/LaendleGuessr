"""
@file item_user.py
@brief Model-Klasse für ItemUser im LaendleGuessr Backend.

Dieses Modul ist als Platzhalter für die ItemUser-Logik vorgesehen.
"""

class ItemUser:
    """Eine Klasse zur Darstellung eines Benutzers und seiner Interaktion mit Items."""

    def __init__(self, user_id, item_id):
        """
        Konstruktor für die ItemUser-Klasse.

        :param user_id: Die eindeutige ID des Benutzers.
        :param item_id: Die eindeutige ID des Items.
        """
        self.user_id = user_id
        self.item_id = item_id

    def __repr__(self):
        """Gibt eine lesbare Darstellung des ItemUser-Objekts zurück."""
        return f"<ItemUser(user_id={self.user_id}, item_id={self.item_id})>"