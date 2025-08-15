import uuid
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field, Relationship
from typing import List, Optional
from datetime import datetime
from pydantic import field_validator
import re

# Таблицы для связи многие ко многим нужны для того чтобы связать карточку с контактной информацией и ссылками
class CardContactInfo(SQLModel, table=True):
    card_id: Optional[UUID] = Field(default=None, foreign_key="card.id", primary_key=True)
    contact_info_id: Optional[UUID] = Field(default=None, foreign_key="contactinfo.id", primary_key=True)

# Таблицы для связи многие ко многим нужны для того чтобы связать карточку с ссылками
class CardLinkWidget(SQLModel, table=True):
    card_id: Optional[UUID] = Field(default=None, foreign_key="card.id", primary_key=True)
    link_widget_id: Optional[UUID] = Field(default=None, foreign_key="linkwidget.id", primary_key=True)

# Таблица для ссылок
class LinkWidget(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    link: str
    icon: Optional[str] = None
    description: Optional[str] = None
    name: str
    cards: List["Card"] = Relationship(back_populates="link_widgets", link_model=CardLinkWidget)
    analytics: List["Analytics"] = Relationship(back_populates="link_widget") 

# Таблица для контактной информации
class ContactInfo(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    icon: Optional[str] = None
    name: str
    description: Optional[str] = None
    cards: List["Card"] = Relationship(back_populates="contact_infos", link_model=CardContactInfo)

# Таблица для событий
class Event(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    date: datetime
    name: str
    place: Optional[str] = None
    contacts: List["Contact"] = Relationship(back_populates="event")

# Таблица для аналитики
class Analytics(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    card_id: UUID = Field(foreign_key="card.id")
    device_type: str  # Например, "desktop", "mobile", "tablet"
    action_type: str  # Например, "view", "share", "add_to_contacts", "link_click"
    link_widget_id: Optional[UUID] = Field(default=None, foreign_key="linkwidget.id")  # Для переходов по ссылкам
    view_timestamp: datetime = Field(default_factory=datetime.utcnow)
    user_agent: Optional[str] = None  # Для хранения полного User-Agent
    card: Optional["Card"] = Relationship(back_populates="analytics")
    link_widget: Optional["LinkWidget"] = Relationship(back_populates=None)  # Связь с LinkWidget

#Таблица элементов карточки
class EditableElement(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    type: str  # допустим что-то типа, 'text', 'shape', 'image'
    matrix: str  # JSON представление of Matrix4
    rotation_angle: float = 0.0
    scale_factor: float = 1.0
    width: float
    height: float
    color: str  # hex цвет, например, '#FFFFFF'
    text: Optional[str] = None
    font_size: Optional[float] = None
    base_font_size: Optional[float] = None
    font_family: Optional[str] = None
    font_weight: Optional[str] = None  # типа, 'bold', 'normal'
    text_color: Optional[str] = None  # hex цвет текста 
    shape_type: Optional[str] = None  # типа, 'rectangle', 'circle'
    image_url: Optional[str] = None  # URL пикчи
    image_opacity: float = 1.0
    card_id: Optional[UUID] = Field(default=None, foreign_key="card.id")
    card: Optional["Card"] = Relationship(back_populates="elements")
    
# Таблица для карточки
class Card(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    avatar: Optional[str] = None
    fullname: str
    company: Optional[str] = None
    position: Optional[str] = None
    about: Optional[str] = None
    user_id: Optional[UUID] = Field(default=None, foreign_key="user.id")
    user: Optional["User"] = Relationship(back_populates="cards")
    contact_infos: List["ContactInfo"] = Relationship(back_populates="cards", link_model=CardContactInfo)
    link_widgets: List["LinkWidget"] = Relationship(back_populates="cards", link_model=CardLinkWidget)
    contacts: List["Contact"] = Relationship(back_populates="card")
    analytics: List["Analytics"] = Relationship(back_populates="card")
    elements: List["EditableElement"] = Relationship(back_populates="card")

# Таблица для пользователя
class User(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    avatar: Optional[str] = None
    name: str
    phone: Optional[str] = None
    email: str
    email_hash: str  # Хэш email для проверки уникальности
    is_premium_user: bool = Field(default=False)
    telegram_authorized: bool = Field(default=False)
    vk_authorized: bool = Field(default=False)
    login: str
    password: str
    cards: List[Card] = Relationship(back_populates="user")
    contacts: List["Contact"] = Relationship(back_populates="user")
    consent_given: bool = Field(default=False)  # Согласие на обработку ПДн
    consent_timestamp: Optional[datetime] = Field(default=None)  # Время предоставления согласия
    created_at: datetime = Field(default_factory=datetime.utcnow)  # Время создания
    updated_at: Optional[datetime] = Field(default=None)  # Время последнего обновления

    @field_validator('phone')
    def validate_phone(cls, v):
        if v:
            pattern = re.compile(r'^(?:\+7|8)?\d{10}$')
            if not pattern.match(v):
                raise ValueError('Invalid phone number format')
        return v

# Таблица для контакта
class Contact(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    card_id: UUID = Field(foreign_key="card.id")
    user_id: UUID = Field(foreign_key="user.id")
    event_id: Optional[UUID] = Field(default=None, foreign_key="event.id")
    card: Card = Relationship(back_populates="contacts")
    user: User = Relationship(back_populates="contacts")
    event: Optional[Event] = Relationship(back_populates="contacts")

class AuditLog(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: Optional[UUID] = Field(default=None, foreign_key="user.id")
    action: str  # "create_user", "update_user", "delete_user"
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    details: Optional[str] = None  
