from fastapi import APIRouter, Depends, HTTPException, Request
from sqlmodel import Session, select, func
from typing import List, Optional
from ..database import get_session
from ..models.models import Card, ContactInfo, LinkWidget, Analytics
from pydantic import BaseModel
from user_agents import parse

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



@router.get("/{card_id}/analytics", response_model=dict)
async def get_card_analytics(card_id: int, session: Session = Depends(get_session)):
        # Проверка существования карточки
        card = session.exec(select(Card).where(Card.id == card_id)).first()
        if not card:
            raise HTTPException(status_code=404, detail="Card not found")

        # Общее количество просмотров карточки
        total_views = session.exec(
            select(func.count()).select_from(Analytics).where(Analytics.card_id == card_id)
        ).one()

        # Просмотры по типам устройств карточки
        views_by_device = session.exec(
            select(Analytics.device_type, func.count())
            .where(Analytics.card_id == card_id)
            .group_by(Analytics.device_type)
        ).all()

        # Формирование ответа
        analytics_data = {
            "card_id": card_id,
            "total_views": total_views,
            "views_by_device": {device_type: count for device_type, count in views_by_device}
        }
        
        return analytics_data


class ActionCreate(BaseModel):
    action_type: str  # "share", "add_to_contacts", "link_click"
    link_widget_id: Optional[int] = None  # Для действия "link_click"

@router.post("/{card_id}/action", response_model=dict)
async def record_action(card_id: int, action: ActionCreate, request: Request, session: Session = Depends(get_session)):
    # Проверка существования карточки
    card = session.exec(select(Card).where(Card.id == card_id)).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")

    # Проверка валидности action_type
    valid_actions = ["share", "add_to_contacts", "link_click"]
    if action.action_type not in valid_actions:
        raise HTTPException(status_code=400, detail="Invalid action type")

    # Проверка link_widget_id для действия "link_click"
    if action.action_type == "link_click" and action.link_widget_id:
        link_widget = session.exec(select(LinkWidget).where(LinkWidget.id == action.link_widget_id)).first()
        if not link_widget:
            raise HTTPException(status_code=404, detail="Link widget not found")

    # Определение типа устройства
    user_agent_string = request.headers.get("user-agent", "")
    user_agent = parse(user_agent_string)
    device_type = "unknown"
    if user_agent.is_mobile:
        device_type = "mobile"
    elif user_agent.is_tablet:
        device_type = "tablet"
    elif user_agent.is_pc:
        device_type = "desktop"

    # Сохранение действия
    analytics_entry = Analytics(
        card_id=card_id,
        device_type=device_type,
        action_type=action.action_type,
        link_widget_id=action.link_widget_id if action.action_type == "link_click" else None,
        user_agent=user_agent_string
    )
    session.add(analytics_entry)
    session.commit()

    return {"message": "Action recorded successfully"}