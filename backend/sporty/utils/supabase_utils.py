# supabase_utils.py
import requests
from django.conf import settings

headers = {
    "apikey": settings.SUPABASE_KEY,
    "Authorization": f"Bearer {settings.SUPABASE_KEY}",
    "Content-Type": "application/json",
}

def fetch_from_supabase(table):
    url = f"{settings.SUPABASE_URL}/rest/v1/{table}"
    return requests.get(url, headers=headers).json()

def insert_to_supabase(table, data):
    url = f"{settings.SUPABASE_URL}/rest/v1/{table}"
    return requests.post(url, json=data, headers=headers).json()
