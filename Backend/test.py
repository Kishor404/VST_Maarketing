import jwt
from datetime import datetime

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM4MjI3Nzk1LCJpYXQiOjE3MzgyMjU5OTUsImp0aSI6ImRmZWQ2Y2EwOGNhNjRlYTZiOWI0ZDFiM2ZlODdkZmQ4IiwidXNlcl9pZCI6OH0.BGka4RodS52hjZC69Kuk4gbs7kAuXQ-zt9SB-VIFBAo"
secret_key = "django-insecure-43x+sm*v3n!uybp24mr)arjqqj-rp%_6$*oy#j-7qk=y7iyoiq"

# Decode the token without verifying the signature
decoded = jwt.decode(token, secret_key, algorithms=["HS256"], options={"verify_exp": False})

print(decoded)
