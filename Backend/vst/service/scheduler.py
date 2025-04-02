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
        staff = service.staff

        # Send notification to customer
        if user and user.FCM_Token:
            user_payload = {
                "token": user.FCM_Token,
                "title": "Service Reminder",
                "body": f"Your scheduled service (ID: {service.id}) is today!"
            }
            try:
                response = requests.post("http://192.168.42.222:8000/firebase/send-notification/", json=user_payload)
                response.raise_for_status()
                print(f"Notification sent to customer {user}: {response.json()}")
            except requests.exceptions.RequestException as e:
                print(f"Error sending notification to customer {user}: {e}")

        # Send notification to staff
        if staff and staff.FCM_Token:
            staff_payload = {
                "token": staff.FCM_Token,
                "title": "Assigned Service Reminder",
                "body": f"You have a scheduled service (ID: {service.id}) to handle today."
            }
            try:
                response = requests.post("http://192.168.42.222:8000/firebase/send-notification/", json=staff_payload)
                response.raise_for_status()
                print(f"Notification sent to staff {staff}: {response.json()}")
            except requests.exceptions.RequestException as e:
                print(f"Error sending notification to staff {staff}: {e}")

def start_scheduler():
    scheduler = BackgroundScheduler()
    scheduler.add_job(send_service_reminder_notifications, "cron", hour=8, minute=0)  # Runs every day at 8 AM
    scheduler.start()
