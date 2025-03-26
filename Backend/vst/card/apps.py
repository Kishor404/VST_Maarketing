from django.apps import AppConfig
import threading


class CardConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'card'

    def ready(self):
        from .scheduler import start_scheduler
        thread = threading.Thread(target=start_scheduler, daemon=True)
        thread.start()
    
