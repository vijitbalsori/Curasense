from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm
from jose import jwt
from datetime import datetime, timedelta
from google.oauth2 import id_token
from google.auth.transport import requests

SECRET = "MY_SECRET"
ALGO = "HS256"
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

router = APIRouter()

fake_db = {}  # replace with actual database


class User(BaseModel):
    email: EmailStr
    password: str = None
    google_id: str = None


def create_token(data: dict):
    data["exp"] = datetime.utcnow() + timedelta(hours=48)
    return jwt.encode(data, SECRET, algorithm=ALGO)


@router.post("/register")
async def register(user: User):
    if user.email in fake_db:
        raise HTTPException(400, "User already exists")

    hashed = pwd_context.hash(user.password)
    fake_db[user.email] = {"email": user.email, "password": hashed}

    return {"message": "Registered successfully"}


@router.post("/login")
async def login(form: OAuth2PasswordRequestForm = Depends()):
    email = form.username
    password = form.password

    if email not in fake_db or not pwd_context.verify(password, fake_db[email]["password"]):
        raise HTTPException(400, "Invalid credentials")

    token = create_token({"email": email})
    return {"access_token": token, "token_type": "bearer"}


GOOGLE_CLIENT_ID = "YOUR_GOOGLE_CLIENT_ID"


@router.post("/google")
async def google_login(token: str):
    try:
        idinfo = id_token.verify_oauth2_token(token, requests.Request(), GOOGLE_CLIENT_ID)

        email = idinfo["email"]
        if email not in fake_db:
            fake_db[email] = {"email": email, "google_id": idinfo["sub"]}

        jwt_token = create_token({"email": email})
        return {"access_token": jwt_token}

    except Exception:
        raise HTTPException(400, "Invalid Google token")
