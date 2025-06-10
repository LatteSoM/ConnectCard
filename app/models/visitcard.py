from sqlmodel import SQLModel, Field, Relationship
from typing import List, Optional
from uuid import UUID, uuid4
from ..config.settings import settings
from sqlalchemy import create_engine

engine = create_engine(settings.DATABASE_URL)

class VisitCard(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    website: Optional[str] = Field(default=None, max_length=255)
    telegram: Optional[str] = Field(default=None, max_length=50, index=True, unique=True)
    linkedin: Optional[str] = Field(default=None, max_length=255)
    github: Optional[str] = Field(default=None, max_length=255, index=True, unique=True)
    twitter: Optional[str] = Field(default=None, max_length=255, index=True, unique=True)
    avatar: Optional[str] = Field(default=None)
    user_id: UUID = Field(foreign_key="user.id")
    user: Optional["User"] = Relationship(back_populates="visit_cards")
    full_name: Optional[str] = Field(default=None, max_length=255)
    company: Optional[str] = Field(default=None, max_length=255)
    position: Optional[str] = Field(default=None, max_length=255)
    about: Optional[str] = Field(default=None, max_length=255)
    event_id: Optional[UUID] = Field(default=None)
    list_of_link_widget: List[str] = Field(default_factory=list)
    list_of_contact_info: List[str] = Field(default_factory=list)

SQLModel.metadata.create_all(engine)