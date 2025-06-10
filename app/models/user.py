from sqlmodel import SQLModel, Field, Relationship
from typing import List, Optional
from pydantic import EmailStr
from uuid import UUID, uuid4
from sqlalchemy import create_engine
from ..config.settings import settings

engine = create_engine(settings.DATABASE_URL)

class User(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    login: str = Field(index=True, max_length=25, unique=True)
    password: str = Field(max_length=255)
    full_name: Optional[str] = Field(default=None, max_length=255)
    email: Optional[EmailStr] = Field(default=None, index=True, unique=True)
    phone: Optional[str] = Field(default=None, max_length=20, index=True, unique=True)
    status: bool = Field(default=False)
    avatar: Optional[str] = Field(default=None)
    is_premium_user: bool = Field(default=False)
    telegram_authorized: bool = Field(default=False)
    vk_authorized: bool = Field(default=False)
    visit_cards: List["VisitCard"] = Relationship(back_populates="user")

SQLModel.metadata.create_all(engine)