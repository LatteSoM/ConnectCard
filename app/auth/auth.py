from fastapi import APIRouter, Depends, HTTPException, status
from ..redis_client import redis_client
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlmodel import Session, select
from datetime import datetime, timedelta
from typing import Optional

from app.encryption import decrypt_data
from ..dependencies import get_session
from ..models.models import User
from .utils import create_refresh_token, verify_password, get_password_hash, create_access_token, ACCESS_TOKEN_EXPIRE_MINUTES, SECRET_KEY, ALGORITHM
from pydantic import BaseModel
from jose import JWTError, jwt
from fastapi import Body


router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str


class TokenData(BaseModel):
    username: Optional[str] = None

class UserCreate(BaseModel):
    login: str
    password: str
    email: str
    name: str

def validate_token_and_get_payload(token: str = Depends(oauth2_scheme)) -> dict:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        jti = payload.get("jti")
        if not jti or redis_client.get(f"revoked:{jti}"):
            raise credentials_exception
        return payload
    except JWTError:
        raise credentials_exception

@router.get("/current_user")
async def get_current_user(
    payload: dict = Depends(validate_token_and_get_payload),
    session: Session = Depends(get_session)
):
    username = payload.get("sub")
    if not username:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    user = session.exec(select(User).where(User.login == username)).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    user.email = decrypt_data(user.email)
    user.name = decrypt_data(user.name)
    user.phone = decrypt_data(user.phone) if user.phone else None
    return user



@router.post("/register", response_model=Token)
def register(user_data: UserCreate, session: Session = Depends(get_session)):
    # Check if user already exists
    existing_user = session.exec(select(User).where(User.login == user_data.login)).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user_data.password)
    db_user = User(
        login=user_data.login,
        password=hashed_password,
        email=user_data.email,
        name=user_data.name
    )
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user_data.login}, expires_delta=access_token_expires
    )

    refresh_token = create_refresh_token(data={"sub": user_data.login})

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/token", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.login == form_data.username)).first()
    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.login}, expires_delta=access_token_expires
    )
    refresh_token = create_refresh_token(data={"sub": user.login})
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/refresh", response_model=Token)
async def refresh_token(refresh_token: str = Body(...)):
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        jti = payload.get("jti")
        exp = payload.get("exp")

        if not username or not jti or not exp:
            raise HTTPException(status_code=401, detail="Invalid token payload")

        # Проверка: уже использован?
        if redis_client.get(f"revoked:{jti}"):
            raise HTTPException(status_code=401, detail="Refresh token revoked or used")

        # Отзываем старый токен
        ttl = int(exp - datetime.utcnow().timestamp())
        redis_client.setex(f"revoked:{jti}", ttl, "true")

        # Генерируем новые токены
        new_access_token = create_access_token(data={"sub": username})
        new_refresh_token = create_refresh_token(data={"sub": username})

        return {
            "access_token": new_access_token,
            "refresh_token": new_refresh_token,
            "token_type": "bearer"
        }

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

@router.post("/logout")
def logout(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        jti = payload.get("jti")
        exp = payload.get("exp")
        if not jti or not exp:
            raise HTTPException(status_code=400, detail="Invalid token structure")

        # времени до истечения токена
        ttl = int(exp - datetime.utcnow().timestamp())
        
        # jti (уникальный ID токена, или айдишник JWT если тебе угодно) вместо полного JWT
        # Кладём jti в Redis
        redis_client.setex(f"revoked:{jti}", ttl, "true")

        return {"message": "Successfully logged out"}

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")




#Register a new User
# curl -X POST "http://localhost:8000/auth/register" \
#      -H "Content-Type: application/json" \
#      -d '{"login": "user1", "password": "password123", "email": "user1@example.com", "name": "User One"}'


#Login
# curl -X POST "http://localhost:8000/auth/token" \
#      -H "Content-Type: application/x-www-form-urlencoded" \
#      -d "username=user1&password=password123"

#Token
# curl -X GET "http://localhost:8000/protected-route" \
#      -H "Authorization: Bearer <your_token>"

#Refresh
# curl -X POST "http://localhost:8000/auth/refresh" \
#      -H "Content-Type: application/json" \
#      -d '{"refresh_token": "<your_refresh_token>"}'
