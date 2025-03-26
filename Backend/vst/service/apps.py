from django.apps import AppConfig
import threading

class ServiceConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "service"

    def ready(self):
        from .scheduler import start_scheduler
        thread = threading.Thread(target=start_scheduler, daemon=True)
        thread.start()
