import jwt
from datetime import datetime

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM4MjE2NjI1LCJpYXQiOjE3MzgyMTQ4MjUsImp0aSI6IjRjNjBmNTU2OGZlNjQ0YmE5ZTQxMTQ3ZmU4NDllZmY5IiwidXNlcl9pZCI6OH0.U_wQibtgYsLi9hDrLKricLezgd-QSEqgXCN9dTBouUA"
secret_key = "django-insecure-43x+sm*v3n!uybp24mr)arjqqj-rp%_6$*oy#j-7qk=y7iyoiq"

# Decode the token without verifying the signature
decoded = jwt.decode(token, secret_key, algorithms=["HS256"], options={"verify_exp": False})

# Check expiration time
exp_timestamp = decoded['exp']
current_time = datetime.utcnow().timestamp()

if current_time > exp_timestamp:
    print("Token has expired.")
else:
    print("Token is valid.")
