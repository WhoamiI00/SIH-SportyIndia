# test_connection.py
import os
import django
from django.conf import settings
from django.db import connection
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure Django settings
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sporty.settings')
django.setup()

def test_database_connection():
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT version();")
            result = cursor.fetchone()
            print("✅ Database connection successful!")
            print(f"PostgreSQL version: {result[0]}")
            return True
    except Exception as e:
        print("❌ Database connection failed!")
        print(f"Error: {e}")
        return False

def test_environment_variables():
    supabase_url = os.getenv("SUPABASE_DB_URL")
    if supabase_url:
        print("✅ SUPABASE_DB_URL found in environment")
        # Don't print the full URL for security
        print(f"URL starts with: {supabase_url[:20]}...")
    else:
        print("❌ SUPABASE_DB_URL not found in environment")
        return False
    return True

if __name__ == "__main__":
    print("Testing Supabase connection...")
    print("-" * 40)
    
    if test_environment_variables():
        test_database_connection()