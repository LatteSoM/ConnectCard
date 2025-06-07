from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from telethon import TelegramClient, errors
from telethon.sessions import StringSession
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()
API_ID = int(os.getenv("API_ID"))
API_HASH = os.getenv("API_HASH")

AVATAR_DIR = "static/avatars"
os.makedirs(AVATAR_DIR, exist_ok=True)

app = FastAPI()

app.mount("/avatars", StaticFiles(directory=AVATAR_DIR), name="avatars")

sessions = {}

class PhoneRequest(BaseModel):
    phone: str

class CodeRequest(BaseModel):
    code: str
    password: str = None

class VerifyCodeRequest(BaseModel):
    phone: str
    code: str
    password: str = None

class TelegramAuth:
    def __init__(self, api_id: int, api_hash: str):
        self.api_id = api_id
        self.api_hash = api_hash
        self.phone_code_hash = None
        self.phone = None
        self.client = None

    async def send_code(self, phone: str) -> bool:
        self.phone = phone
        self.client = TelegramClient(StringSession(), self.api_id, self.api_hash)
        await self.client.connect()

        try:
            result = await self.client.send_code_request(phone)
            self.phone_code_hash = result.phone_code_hash
            return True
        except errors.PhoneMigrateError as e:
            await self.client.disconnect()
            self.client = TelegramClient(StringSession(), self.api_id, self.api_hash, dc_id=e.new_dc)
            await self.client.connect()
            result = await self.client.send_code_request(phone)
            self.phone_code_hash = result.phone_code_hash
            return True
        except Exception as e:
            print(f"[send_code] Error: {e}")
            return False

    async def sign_in(self, code: str, password: str = None):
        if not self.client or not self.phone_code_hash:
            raise RuntimeError("Call send_code() first")

        try:
            await self.client.sign_in(phone=self.phone, code=code, phone_code_hash=self.phone_code_hash)
        except errors.SessionPasswordNeededError:
            if not password:
                raise ValueError("2FA password required")
            await self.client.sign_in(password=password)

        me = await self.client.get_me()

        avatar_filename = f"{me.id}_avatar.jpg"
        avatar_path = os.path.join(AVATAR_DIR, avatar_filename)
        try:
            await self.client.download_profile_photo(me, file=avatar_path)
        except Exception as e:
            print(f"[avatar] Failed to download avatar: {e}")
            avatar_filename = None  # Нет аватарки

        return {
            "user_id": me.id,
            "username": me.username,
            "first_name": me.first_name,
            "last_name": me.last_name,
            "phone": self.phone,
            "avatar_url": f"/avatars/{avatar_filename}" if avatar_filename else None
        }

@app.post("/request_code")
async def request_code(request: PhoneRequest):
    auth = TelegramAuth(API_ID, API_HASH)
    if not await auth.send_code(request.phone):
        raise HTTPException(status_code=400, detail="Failed to send code")
    sessions[request.phone] = auth
    return {"status": "Code sent"}

@app.post("/verify_code")
async def verify_code(request: VerifyCodeRequest):
    if request.phone not in sessions:
        raise HTTPException(status_code=404, detail="Session not found. Call /request_code first.")

    auth = sessions[request.phone]
    try:
        result = await auth.sign_in(request.code, request.password)
    
        response_data = {
            "status": "Success",
            "user": {
                "user_id": result["user_id"],
                "username": result["username"],
                "first_name": result["first_name"],
                "last_name": result["last_name"],
                "phone": result.get("phone"),
                "avatar_url": result["avatar_url"]
            }
        }

        return JSONResponse(content=response_data, media_type="application/json; charset=utf-8")
    except ValueError as e:
        raise HTTPException(status_code=403, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Authorization failed: {e}")
