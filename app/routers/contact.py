from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models.models import Contact, Card, User, Event
from pydantic import BaseModel

router = APIRouter(
    prefix="/contacts",
    tags=["contacts"]
)

class ContactBase(BaseModel):
    card_id: int
    user_id: int
    event_id: int | None = None

class ContactCreate(ContactBase):
    pass

class ContactResponse(ContactBase):
    id: int
    card: Card
    user: User
    event: Event | None = None

    class Config:
        from_attributes = True
        arbitrary_types_allowed = True

@router.post("/", response_model=ContactResponse)
def create_contact(contact: ContactCreate, session: Session = Depends(get_session)):
    # Verify that card and user exist
    card = session.exec(select(Card).where(Card.id == contact.card_id)).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    user = session.exec(select(User).where(User.id == contact.user_id)).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Verify event if provided
    if contact.event_id:
        event = session.exec(select(Event).where(Event.id == contact.event_id)).first()
        if not event:
            raise HTTPException(status_code=404, detail="Event not found")
    
    # Create contact
    db_contact = Contact(**contact.model_dump())
    session.add(db_contact)
    session.commit()
    session.refresh(db_contact)
    return db_contact

@router.get("/", response_model=List[ContactResponse])
def read_contacts(skip: int = 0, limit: int = 100, session: Session = Depends(get_session)):
    contacts = session.exec(select(Contact).offset(skip).limit(limit)).all()
    return contacts

@router.get("/{contact_id}", response_model=ContactResponse)
def read_contact(contact_id: int, session: Session = Depends(get_session)):
    contact = session.exec(select(Contact).where(Contact.id == contact_id)).first()
    if contact is None:
        raise HTTPException(status_code=404, detail="Contact not found")
    return contact

@router.put("/{contact_id}", response_model=ContactResponse)
def update_contact(contact_id: int, contact: ContactCreate, session: Session = Depends(get_session)):
    db_contact = session.exec(select(Contact).where(Contact.id == contact_id)).first()
    if db_contact is None:
        raise HTTPException(status_code=404, detail="Contact not found")
    
    # Verify that card and user exist
    card = session.exec(select(Card).where(Card.id == contact.card_id)).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    user = session.exec(select(User).where(User.id == contact.user_id)).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Verify event if provided
    if contact.event_id:
        event = session.exec(select(Event).where(Event.id == contact.event_id)).first()
        if not event:
            raise HTTPException(status_code=404, detail="Event not found")
    
    # Update contact
    for key, value in contact.model_dump().items():
        setattr(db_contact, key, value)
    
    session.commit()
    session.refresh(db_contact)
    return db_contact

@router.delete("/{contact_id}")
def delete_contact(contact_id: int, session: Session = Depends(get_session)):
    contact = session.exec(select(Contact).where(Contact.id == contact_id)).first()
    if contact is None:
        raise HTTPException(status_code=404, detail="Contact not found")
    
    session.delete(contact)
    session.commit()
    return {"message": "Contact deleted successfully"} 