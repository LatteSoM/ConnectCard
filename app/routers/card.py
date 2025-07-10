from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models.models import Card, ContactInfo, LinkWidget
from pydantic import BaseModel

router = APIRouter(
    prefix="/cards",
    tags=["cards"]
)

class CardBase(BaseModel):
    avatar: str | None = None
    fullname: str
    company: str | None = None
    position: str | None = None
    about: str | None = None

class CardCreate(CardBase):
    contact_info_ids: List[int] = []
    link_widget_ids: List[int] = []

class CardResponse(CardBase):
    id: int
    contact_infos: List[ContactInfo]
    link_widgets: List[LinkWidget]

    class Config:
        from_attributes = True
        arbitrary_types_allowed = True

@router.post("/", response_model=CardResponse)
def create_card(card: CardCreate, session: Session = Depends(get_session)):
    # Create base card
    db_card = Card(
        avatar=card.avatar,
        fullname=card.fullname,
        company=card.company,
        position=card.position,
        about=card.about
    )
    session.add(db_card)
    session.commit()
    session.refresh(db_card)

    # Add contact infos
    if card.contact_info_ids:
        contact_infos = session.exec(select(ContactInfo).where(ContactInfo.id.in_(card.contact_info_ids))).all()
        db_card.contact_infos.extend(contact_infos)

    # Add link widgets
    if card.link_widget_ids:
        link_widgets = session.exec(select(LinkWidget).where(LinkWidget.id.in_(card.link_widget_ids))).all()
        db_card.link_widgets.extend(link_widgets)

    session.commit()
    session.refresh(db_card)
    return db_card

@router.get("/", response_model=List[CardResponse])
def read_cards(skip: int = 0, limit: int = 100, session: Session = Depends(get_session)):
    cards = session.exec(select(Card).offset(skip).limit(limit)).all()
    return cards

@router.get("/{card_id}", response_model=CardResponse)
def read_card(card_id: int, session: Session = Depends(get_session)):
    card = session.exec(select(Card).where(Card.id == card_id)).first()
    if card is None:
        raise HTTPException(status_code=404, detail="Card not found")
    return card

@router.put("/{card_id}", response_model=CardResponse)
def update_card(card_id: int, card: CardCreate, session: Session = Depends(get_session)):
    db_card = session.exec(select(Card).where(Card.id == card_id)).first()
    if db_card is None:
        raise HTTPException(status_code=404, detail="Card not found")
    
    # Update basic fields
    for key, value in card.model_dump(exclude={'contact_info_ids', 'link_widget_ids'}).items():
        setattr(db_card, key, value)
    
    # Update contact infos
    if card.contact_info_ids:
        contact_infos = session.exec(select(ContactInfo).where(ContactInfo.id.in_(card.contact_info_ids))).all()
        db_card.contact_infos = contact_infos

    # Update link widgets
    if card.link_widget_ids:
        link_widgets = session.exec(select(LinkWidget).where(LinkWidget.id.in_(card.link_widget_ids))).all()
        db_card.link_widgets = link_widgets

    session.commit()
    session.refresh(db_card)
    return db_card

@router.delete("/{card_id}")
def delete_card(card_id: int, session: Session = Depends(get_session)):
    card = session.exec(select(Card).where(Card.id == card_id)).first()
    if card is None:
        raise HTTPException(status_code=404, detail="Card not found")
    
    session.delete(card)
    session.commit()
    return {"message": "Card deleted successfully"} 


@router.get("/{card_id}/qr-link", response_model=dict)
async def get_card_qr_link(card_id: int, session: Session = Depends(get_session)):
    
    card = session.exec(select(Card).where(Card.id == card_id)).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    # Формируем ссылку для QR-кода
    qr_link = f"https://connectcard.ru/users/{card_id}"
    return {"qr_link": qr_link}