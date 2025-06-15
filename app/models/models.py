from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Table
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

# Association table for Card-ContactInfo relationship
card_contact_info = Table('card_contact_info', Base.metadata,
    Column('card_id', Integer, ForeignKey('card.id')),
    Column('contact_info_id', Integer, ForeignKey('contactinfo.id'))
)

# Association table for Card-LinkWidget relationship
card_link_widget = Table('card_link_widget', Base.metadata,
    Column('card_id', Integer, ForeignKey('card.id')),
    Column('link_widget_id', Integer, ForeignKey('linkwidget.id'))
)

class LinkWidget(Base):
    __tablename__ = 'linkwidget'
    
    id = Column(Integer, primary_key=True)
    link = Column(String(255), nullable=False)
    icon = Column(String(255))
    description = Column(String(500))
    name = Column(String(100), nullable=False)

class ContactInfo(Base):
    __tablename__ = 'contactinfo'
    
    id = Column(Integer, primary_key=True)
    icon = Column(String(255))
    name = Column(String(100), nullable=False)
    description = Column(String(500))

class Event(Base):
    __tablename__ = 'event'
    
    id = Column(Integer, primary_key=True)
    date = Column(DateTime, nullable=False)
    name = Column(String(100), nullable=False)
    place = Column(String(255))
    contacts = relationship('Contact', back_populates='event')

class Card(Base):
    __tablename__ = 'card'
    
    id = Column(Integer, primary_key=True)
    avatar = Column(String(255))
    fullname = Column(String(100), nullable=False)
    company = Column(String(100))
    position = Column(String(100))
    about = Column(String(1000))
    
    # Relationships
    contact_infos = relationship('ContactInfo', secondary=card_contact_info, backref='cards')
    link_widgets = relationship('LinkWidget', secondary=card_link_widget, backref='cards')
    contacts = relationship('Contact', back_populates='card')

class User(Base):
    __tablename__ = 'user'
    
    id = Column(Integer, primary_key=True)
    avatar = Column(String(255))
    name = Column(String(100), nullable=False)
    phone = Column(String(20))
    email = Column(String(100), unique=True, nullable=False)
    is_premium_user = Column(Boolean, default=False)
    telegram_authorized = Column(Boolean, default=False)
    vk_authorized = Column(Boolean, default=False)
    login = Column(String(50), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    
    # Relationships
    cards = relationship('Card', backref='user')
    contacts = relationship('Contact', back_populates='user')

class Contact(Base):
    __tablename__ = 'contact'
    
    id = Column(Integer, primary_key=True)
    card_id = Column(Integer, ForeignKey('card.id'), nullable=False)
    user_id = Column(Integer, ForeignKey('user.id'), nullable=False)
    event_id = Column(Integer, ForeignKey('event.id'))
    
    # Relationships
    card = relationship('Card', back_populates='contacts')
    user = relationship('User', back_populates='contacts')
    event = relationship('Event', back_populates='contacts')
