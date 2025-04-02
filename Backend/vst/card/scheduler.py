import requests
from apscheduler.schedulers.background import BackgroundScheduler
from django.utils.timezone import now
from card.models import Card
from card.models import ServiceEntry

def send_warranty_expiry_notifications():
    today = now().date()
    reminder_days = [10, 5, 3, 1, 0]  # Notify on these days before expiry

    cards = Card.objects.all()

    print("WARRANTY EXPIRY NOTIFICATIONS")

    for card in cards:
        days_remaining = (card.warranty_end_date - today).days

        if days_remaining in reminder_days:
            user = card.customer_code
            if user.FCM_Token:
                payload = {
                    "token": user.FCM_Token,
                    "title": "Warranty Expiry Reminder",
                    "body": f"Your warranty for Card ID {card.id} expires in {days_remaining} days!"
                    if days_remaining > 0 else f"Your warranty for Card ID {card.id} expires today!"
                }
                try:
                    response = requests.post("http://192.168.42.222:8000/firebase/send-notification/", json=payload)
                    response.raise_for_status()
                    print(f"Notification sent to {user}: {response.json()}")
                except requests.exceptions.RequestException as e:
                    print(f"Error sending notification to {user}: {e}")


def send_next_service():
    today = now().date()

    services = ServiceEntry.objects.filter(next_service=today)

    print("NEXT SERVICE NOTIFICATIONS")

    for service in services:
        user = service.card.customer_code
        if user.FCM_Token:
            payload = {
                "token": user.FCM_Token,
                "title": "Book Service Now",
                "body": f"Time To Book Your Next Service"
            }
            try:
                response = requests.post("http://192.168.42.222:8000/firebase/send-notification/", json=payload)
                response.raise_for_status()
                print(f"Notification sent to {user}: {response.json()}")
            except requests.exceptions.RequestException as e:
                print(f"Error sending notification to {user}: {e}")


def start_scheduler():
    scheduler = BackgroundScheduler()
    scheduler.add_job(send_warranty_expiry_notifications, "cron", hour=9, minute=0)
    scheduler.add_job(send_next_service, "cron", hour=10, minute=0)
    scheduler.start()
