from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models.models import User, Card
from pydantic import BaseModel, EmailStr
from passlib.context import CryptContext

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class UserBase(BaseModel):
    avatar: str | None = None
    name: str
    phone: str | None = None
    email: EmailStr
    is_premium_user: bool = False
    telegram_authorized: bool = False
    vk_authorized: bool = False
    login: str

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    avatar: str | None = None
    name: str | None = None
    phone: str | None = None
    email: EmailStr | None = None
    login: str | None = None
    password: str | None = None 
    is_premium_user: bool | None = None
    telegram_authorized: bool | None = None
    vk_authorized: bool | None = None

class UserResponse(UserBase):
    id: int
    cards: List[Card]

    class Config:
        from_attributes = True

def get_password_hash(password: str):
    return pwd_context.hash(password)

@router.post("/", response_model=UserResponse)
def create_user(user: UserCreate, session: Session = Depends(get_session)):
    # Check if user with same email or login exists
    if session.exec(select(User).where(User.email == user.email)).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    if session.exec(select(User).where(User.login == user.login)).first():
        raise HTTPException(status_code=400, detail="Login already taken")
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = User(
        avatar=user.avatar,
        name=user.name,
        phone=user.phone,
        email=user.email,
        is_premium_user=user.is_premium_user,
        telegram_authorized=user.telegram_authorized,
        vk_authorized=user.vk_authorized,
        login=user.login,
        password=hashed_password
    )
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

@router.get("/", response_model=List[UserResponse])
def read_users(skip: int = 0, limit: int = 100, session: Session = Depends(get_session)):
    users = session.exec(select(User).offset(skip).limit(limit)).all()
    return users

@router.get("/{user_id}", response_model=UserResponse)
def read_user(user_id: int, session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.id == user_id)).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.put("/{user_id}", response_model=UserResponse)
def update_user(user_id: int, user: UserUpdate, session: Session = Depends(get_session)):
    db_user = session.exec(select(User).where(User.id == user_id)).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Check if new email or login is already taken by another user
    if user.email != db_user.email:
        if session.exec(select(User).where(User.email == user.email)).first():
            raise HTTPException(status_code=400, detail="Email already registered")
    if user.login != db_user.login:
        if session.exec(select(User).where(User.login == user.login)).first():
            raise HTTPException(status_code=400, detail="Login already taken")
    
    # Update user fields
    for key, value in user.model_dump(exclude={'password'}).items():
        setattr(db_user, key, value)
    
    # Update password if provided
    if user.password:
        db_user.password = get_password_hash(user.password)
    
    session.commit()
    session.refresh(db_user)
    return db_user

@router.delete("/{user_id}")
def delete_user(user_id: int, session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.id == user_id)).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    session.delete(user)
    session.commit()
    return {"message": "User deleted successfully"} 