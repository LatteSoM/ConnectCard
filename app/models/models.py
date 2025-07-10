from sqlmodel import SQLModel, Field, Relationship
from typing import List, Optional
from datetime import datetime

# Association tables must be defined first
class CardContactInfo(SQLModel, table=True):
    card_id: Optional[int] = Field(default=None, foreign_key="card.id", primary_key=True)
    contact_info_id: Optional[int] = Field(default=None, foreign_key="contactinfo.id", primary_key=True)

class CardLinkWidget(SQLModel, table=True):
    card_id: Optional[int] = Field(default=None, foreign_key="card.id", primary_key=True)
    link_widget_id: Optional[int] = Field(default=None, foreign_key="linkwidget.id", primary_key=True)

class LinkWidget(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    link: str
    icon: Optional[str] = None
    description: Optional[str] = None
    name: str
    cards: List["Card"] = Relationship(back_populates="link_widgets", link_model=CardLinkWidget)

class ContactInfo(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    icon: Optional[str] = None
    name: str
    description: Optional[str] = None
    cards: List["Card"] = Relationship(back_populates="contact_infos", link_model=CardContactInfo)

class Event(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    date: datetime
    name: str
    place: Optional[str] = None
    contacts: List["Contact"] = Relationship(back_populates="event")

class Analytics(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    card_id: int = Field(foreign_key="card.id")
    device_type: str  # Например, "desktop", "mobile", "tablet"
    view_timestamp: datetime = Field(default_factory=datetime.utcnow)
    user_agent: Optional[str] = None  # Для хранения полного User-Agent
    card: Optional["Card"] = Relationship(back_populates="analytics")

class Card(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    avatar: Optional[str] = None
    fullname: str
    company: Optional[str] = None
    position: Optional[str] = None
    about: Optional[str] = None
    user_id: Optional[int] = Field(default=None, foreign_key="user.id")
    user: Optional["User"] = Relationship(back_populates="cards")
    contact_infos: List[ContactInfo] = Relationship(back_populates="cards", link_model=CardContactInfo)
    link_widgets: List[LinkWidget] = Relationship(back_populates="cards", link_model=CardLinkWidget)
    contacts: List["Contact"] = Relationship(back_populates="card")
    analytics: List["Analytics"] = Relationship(back_populates="card") 

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    avatar: Optional[str] = None
    name: str
    phone: Optional[str] = None
    email: str
    is_premium_user: bool = Field(default=False)
    telegram_authorized: bool = Field(default=False)
    vk_authorized: bool = Field(default=False)
    login: str
    password: str
    cards: List[Card] = Relationship(back_populates="user")
    contacts: List["Contact"] = Relationship(back_populates="user")

class Contact(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    card_id: int = Field(foreign_key="card.id")
    user_id: int = Field(foreign_key="user.id")
    event_id: Optional[int] = Field(default=None, foreign_key="event.id")
    card: Card = Relationship(back_populates="contacts")
    user: User = Relationship(back_populates="contacts")
    event: Optional[Event] = Relationship(back_populates="contacts")
