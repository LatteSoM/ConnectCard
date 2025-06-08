from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Query
from pydantic import EmailStr
from sqlmodel import Field, Relationship, Session, SQLModel, create_engine, select
from uuid import UUID, uuid4
from datetime import datetime

class User(SQLModel, table=True):
    id: UUID | None = Field(default_factory=uuid4, primary_key=True)
    login: str = Field(index=True, max_length=25, unique=True)
    password: str = Field(max_length=255)
    full_name: str | None = Field(default=None, max_length=255)
    email: EmailStr | None = Field(default=None, index=True, unique=True)
    phone: str | None = Field(default=None, max_length=20, index=True, unique=True)
    is_premium_user: bool = Field(default=False)
    telegram_authorized: bool = Field(default=False)
    vk_authorized: bool = Field(default=False)
    avatar: str | None = Field(default=None)
    visit_cards: list["VisitCard"] = Relationship(back_populates="user")

class VisitCard(SQLModel, table=True):
    id: UUID | None = Field(default_factory=uuid4, primary_key=True)
    full_name: str | None = Field(default=None, max_length=255)
    company: str | None = Field(default=None, max_length=255)
    poistion: str | None = Field(default=None, max_length=255)
    about: str | None = Field(default=None, max_length=255)
    avatar: str | None = Field(default=None)
    user_id: UUID = Field(foreign_key="user.id")
    user: User = Relationship(back_populates="visit_cards")
    contact_info: list["ContactInfo"] = Relationship(back_populates="visit_cards")
    link_widget: list["LinkWidget"] = Relationship(back_populates="visit_cards")
    
class LinkWidget(SQLModel, table=True):
    id: UUID | None = Field(default_factory=uuid4, primary_key=True)
    link: str | None = Field(default=None)
    icon: str | None = Field(default=None)
    description: str | None = Field(default=None, max_length=255)
    name: str | None = Field(default=None, max_length=255)
    visit_card_id: UUID = Field(foreign_key="visitcard.id")
    visit_card: "VisitCard" = Relationship(back_populates="link_widget")

class ContactInfo(SQLModel, table=True):
    id: UUID | None = Field(default_factory=uuid4, primary_key=True)
    icon: str | None = Field(default=None)
    name: str | None = Field(default=None, max_length=255)
    description: str | None = Field(default=None, max_length=255)
    visit_card_id: UUID = Field(foreign_key="visitcard.id")
    visit_card: "VisitCard" = Relationship(back_populates="contact_info")

class Event(SQLModel, table=True):
    id: UUID | None = Field(default_factory=uuid4, primary_key=True)
    date: datetime | None = Field(default=None)
    name: str | None = Field(default=None, max_length=255, index=True)
    place: str | None = Field(default=None, max_length=255, index=True)

class Contact(SQLModel, table=True):
    id: UUID | None = Field(default_factory=uuid4, primary_key=True)
    card_id: UUID = Field(foreign_key="visitcard.id")
    user_id: UUID = Field(foreign_key="user.id")
    event_id: UUID = Field(foreign_key="event.id")
