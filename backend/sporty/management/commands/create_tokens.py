# Create a management command: management/commands/create_tokens.py
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token

class Command(BaseCommand):
    def handle(self, *args, **options):
        User = get_user_model()
        for user in User.objects.all():
            Token.objects.get_or_create(user=user)
        self.stdout.write('Created tokens for all users')