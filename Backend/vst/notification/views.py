from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from firebase_admin import messaging

@csrf_exempt
def send_notification(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            token = data.get("token")
            title = data.get("title")
            body = data.get("body")

            # Prepare the message
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                token=token,
            )

            # Send the notification
            response = messaging.send(message)
            return JsonResponse({"message": "Notification sent successfully", "response": response}, status=200)

        except Exception as e:
            return JsonResponse({"message": "Failed to send notification", "error": str(e)}, status=500)

    return JsonResponse({"message": "Invalid request method"}, status=400)
