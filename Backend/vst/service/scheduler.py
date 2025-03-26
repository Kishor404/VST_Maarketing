import requests
from apscheduler.schedulers.background import BackgroundScheduler
from django.utils.timezone import now
from service.models import Service

def send_service_reminder_notifications():
    today = now().date()
    services = Service.objects.filter(available_date=today)

    print("SERVICE REMINDER NOTIFICATIONS")

    for service in services:
        user = service.customer
        if user.FCM_Token:
            payload = {
                "token": user.FCM_Token,
                "title": "Service Reminder",
                "body": f"Your scheduled service (ID: {service.id}) is today!"
            }
            try:
                response = requests.post("http://192.168.141.222:8000/firebase/send-notification/", json=payload)
                response.raise_for_status()
                print(f"Notification sent to {user}: {response.json()}")
            except requests.exceptions.RequestException as e:
                print(f"Error sending notification to {user}: {e}")

def start_scheduler():
    scheduler = BackgroundScheduler()
    scheduler.add_job(send_service_reminder_notifications, "cron", hour=8, minute=0)  # Runs every day at 8 AM
    scheduler.start()
