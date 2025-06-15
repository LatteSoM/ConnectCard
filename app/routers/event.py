from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models.models import Event
from pydantic import BaseModel
from datetime import datetime

router = APIRouter(
    prefix="/events",
    tags=["events"]
)

class EventBase(BaseModel):
    date: datetime
    name: str
    place: str | None = None

class EventCreate(EventBase):
    pass

class EventResponse(EventBase):
    id: int

    class Config:
        from_attributes = True

@router.post("/", response_model=EventResponse)
def create_event(event: EventCreate, session: Session = Depends(get_session)):
    db_event = Event(**event.model_dump())
    session.add(db_event)
    session.commit()
    session.refresh(db_event)
    return db_event

@router.get("/", response_model=List[EventResponse])
def read_events(skip: int = 0, limit: int = 100, session: Session = Depends(get_session)):
    events = session.exec(select(Event).offset(skip).limit(limit)).all()
    return events

@router.get("/{event_id}", response_model=EventResponse)
def read_event(event_id: int, session: Session = Depends(get_session)):
    event = session.exec(select(Event).where(Event.id == event_id)).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    return event

@router.put("/{event_id}", response_model=EventResponse)
def update_event(event_id: int, event: EventCreate, session: Session = Depends(get_session)):
    db_event = session.exec(select(Event).where(Event.id == event_id)).first()
    if db_event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    
    for key, value in event.model_dump().items():
        setattr(db_event, key, value)
    
    session.commit()
    session.refresh(db_event)
    return db_event

@router.delete("/{event_id}")
def delete_event(event_id: int, session: Session = Depends(get_session)):
    event = session.exec(select(Event).where(Event.id == event_id)).first()
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    
    session.delete(event)
    session.commit()
    return {"message": "Event deleted successfully"} 