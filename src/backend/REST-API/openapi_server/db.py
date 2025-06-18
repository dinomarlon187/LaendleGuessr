"""
@file db.py
@brief Supabase-Client-Initialisierung für das LaendleGuessr Backend.

Dieses Modul stellt den Supabase-Client für Datenbankzugriffe bereit.
"""

import os
from supabase import create_client, Client
from openapi_server.logger import logger

supabase_url: str = "https://ipjfhqmcqlwlrjqanjqk.supabase.co"
supabase_key: str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwamZocW1jcWx3bHJqcWFuanFrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NzUxNDA0NCwiZXhwIjoyMDYzMDkwMDQ0fQ.5VpSCVmfUZ02Tbs5fHPL5vJsfJqvC_s6CggESbRCQQs"
supabase: Client = create_client(supabase_url, supabase_key)
logger.info("Supabase-Client initialisiert.")