import json
from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, messaging

app = Flask(__name__)

# Load the service account key
cred = credentials.Certificate("./certificate.json")
firebase_admin.initialize_app(cred)

@app.route("/send-notification", methods=["POST"])
def send_notification():
    try:
        data = request.get_json()
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
        return jsonify({"message": "Notification sent successfully", "response": response}), 200

    except Exception as e:
        return jsonify({"message": "Failed to send notification", "error": str(e)}), 500

if __name__ == "__main__":
    PORT = 3000
    app.run(host="0.0.0.0", port=PORT)
