import json
import os
import shutil
import uuid
from fastapi import APIRouter, Depends, File, Form, HTTPException, Request, Query, UploadFile
from datetime import datetime
from sqlmodel import Session, select, func
from typing import List, Optional
from uuid import UUID, uuid4

from app.config.config import AVATAR_DIR

from ..auth.auth import get_current_user
from ..database import get_session
from ..models.models import Card, ContactInfo, LinkWidget, Analytics, User, EditableElement
from pydantic import BaseModel
from user_agents import parse

router = APIRouter(
    prefix="/cards",
    tags=["cards"]
)

class EditableElementBase(BaseModel):
    temp_id: str
    type: str
    matrix: str
    rotation_angle: float = 0.0
    scale_factor: float = 1.0
    width: float
    height: float
    color: str
    text: Optional[str] = None
    font_size: Optional[float] = None
    base_font_size: Optional[float] = None
    font_family: Optional[str] = None
    font_weight: Optional[str] = None
    text_color: Optional[str] = None
    shape_type: Optional[str] = None
    image_url: Optional[str] = None
    image_opacity: float = 1.0
    clip_type: Optional[str] = None
    link_type: Optional[str] = None
    background_link_color: Optional[str] = None

class EditableElementResponse(EditableElementBase):
    id: UUID

class EditableElementCreate(EditableElementBase):
    pass


class CardBase(BaseModel):
    avatar: str | None = None
    fullname: str
    company: str | None = None
    position: str | None = None
    about: str | None = None
    template: str | None = None

class CardCreate(CardBase):
    contact_info_ids: List[UUID] = []
    link_widget_ids: List[UUID] = []
    elements: List[EditableElementCreate] = []

class CardResponse(CardBase):
    id: UUID
    contact_infos: List[ContactInfo]
    link_widgets: List[LinkWidget]
    elements: List[EditableElementCreate] = []

    class Config:
        from_attributes = True
        arbitrary_types_allowed = True
        
class ActionCreate(BaseModel):
    action_type: str  # "share", "add_to_contacts", "link_click"
    link_widget_id: Optional[UUID] = None  # Для действия "link_click"


@router.post("/", response_model=CardResponse)
def create_card(data: str = Form(...), avatar: UploadFile | None = File(None), element_images: list[UploadFile] = File([]), current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    
    card = CardCreate(**json.loads(data))

    avatar_path = None
    if avatar:
        ext = os.path.splitext(avatar.filename)[1]
        filename = f"{uuid.uuid4()}{ext}"
        path = os.path.join(AVATAR_DIR, filename)
        with open(path, "wb") as buffer:
            shutil.copyfileobj(avatar.file, buffer)
        avatar_path = f"/avatars/{filename}"
    
    # Create base card
    db_card = Card(
        avatar=avatar_path or card.avatar,
        fullname=card.fullname,
        company=card.company,
        position=card.position,
        about=card.about,
        user_id=current_user.id,
        template=card.template,
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
        
    # for elem_data in card.elements:
    #     db_element = EditableElement(**elem_data.model_dump(), card_id=db_card.id)
    #     session.add(db_element)
    element_files_map = {f.filename.split("_")[0]: f for f in element_images}

    # Добавляем элементы
    for elem_data in card.elements:
        image_url = None
        if elem_data.type == "image" and getattr(elem_data, "temp_id", None):
            f = element_files_map.get(elem_data.temp_id)
            if f:
                ext = os.path.splitext(f.filename)[1]
                filename = f"{uuid.uuid4()}{ext}"
                path = os.path.join(AVATAR_DIR, filename)
                with open(path, "wb") as buffer:
                    shutil.copyfileobj(f.file, buffer)
                image_url = f"/avatars/{filename}"

        elem_dict = elem_data.model_dump()
        elem_dict['image_url'] = image_url  # перезаписываем
        db_element = EditableElement(**elem_dict, card_id=db_card.id)
        session.add(db_element)


    session.commit()
    session.refresh(db_card)
    return db_card

@router.post("/{card_id}/avatar", response_model=CardResponse)
async def upload_avatar(
    card_id: UUID,
    avatar: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    db_card = session.get(Card, card_id)
    if not db_card or db_card.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Card not found")

    ext = os.path.splitext(avatar.filename)[1]
    filename = f"{uuid4()}{ext}"
    avatar_path = os.path.join(AVATAR_DIR, filename)

    with open(avatar_path, "wb") as buffer:
        shutil.copyfileobj(avatar.file, buffer)

    db_card.avatar = f"/avatars/{filename}"
    session.add(db_card)
    session.commit()
    session.refresh(db_card)
    return db_card

@router.get("/", response_model=List[CardResponse])
def read_cards(skip: int = 0, limit: int = 100, session: Session = Depends(get_session)):
    cards = session.exec(select(Card).offset(skip).limit(limit)).all()
    return cards

@router.get("/{card_id}", response_model=CardResponse)
def read_card(card_id: UUID, session: Session = Depends(get_session)):
    card = session.exec(select(Card).where(Card.id == card_id)).first()
    if card is None:
        raise HTTPException(status_code=404, detail="Card not found")
    return card

@router.get("/user/{user_id}", response_model=List[CardResponse])
def read_user_cards(
    user_id: UUID,
    session: Session = Depends(get_session)
):
    """
    Получает ВСЕ3 карточки, принадлежащие конкретному пользователю.
    
    Параметры:
    - user_id: ID пользователя
    """
    cards = session.exec(
        select(Card)
        .where(Card.user_id == user_id)
    ).all()
    
    # if not cards:
    #     raise HTTPException(
    #         status_code=404,
    #         detail=f"No cards found for user with id {user_id}"
    #     )
    
    return cards

@router.put("/{card_id}", response_model=CardResponse)
def update_card(
    card_id: UUID, 
    data: str = Form(...), 
    avatar: UploadFile | None = File(None), 
    element_images: list[UploadFile] = File([]), 
    session: Session = Depends(get_session)
):
    db_card = session.exec(select(Card).where(Card.id == card_id)).first()
    if db_card is None:
        raise HTTPException(status_code=404, detail="Card not found")
    
    card = CardCreate(**json.loads(data))

    # ---------- Обновляем аватар ----------
    if avatar:
        # Удаляем старый аватар, если он существует
        if db_card.avatar and os.path.exists(db_card.avatar.replace("/avatars/", AVATAR_DIR + "/")):
            try:
                os.remove(db_card.avatar.replace("/avatars/", AVATAR_DIR + "/"))
            except OSError:
                pass
        
        # Сохраняем новый аватар
        ext = os.path.splitext(avatar.filename)[1]
        filename = f"{uuid.uuid4()}{ext}"
        path = os.path.join(AVATAR_DIR, filename)
        with open(path, "wb") as buffer:
            shutil.copyfileobj(avatar.file, buffer)
        db_card.avatar = f"/avatars/{filename}"
    
    # ---------- Обновляем простые поля ----------
    simple_fields = ['fullname', 'company', 'position', 'about', 'template']
    update_data = {k: v for k, v in card.model_dump(exclude_unset=True).items() 
        if k in simple_fields and v is not None}

    for key, value in update_data.items():
        setattr(db_card, key, value)
    
    # ---------- Обновляем контакты ----------
    if card.contact_info_ids:
        contact_infos = session.exec(
            select(ContactInfo).where(ContactInfo.id.in_(card.contact_info_ids))
        ).all()
        db_card.contact_infos = contact_infos
    else:
        db_card.contact_infos = []

    # ---------- Обновляем виджеты ссылок ----------
    if card.link_widget_ids:
        link_widgets = session.exec(
            select(LinkWidget).where(LinkWidget.id.in_(card.link_widget_ids))
        ).all()
        db_card.link_widgets = link_widgets
    else:
        db_card.link_widgets = []
    
    # ---------- Обрабатываем элементы ----------
    element_files_map = {f.filename.split("_")[0]: f for f in element_images}
    new_elements = []

    for elem_data in card.elements:
        image_url = elem_data.image_url  # по умолчанию оставляем старый

        # Если новый файл (через temp_id)
        if elem_data.type == "image" and getattr(elem_data, "temp_id", None):
            f = element_files_map.get(elem_data.temp_id)
            if f:
                ext = os.path.splitext(f.filename)[1]
                filename = f"{uuid.uuid4()}{ext}"
                path = os.path.join(AVATAR_DIR, filename)
                with open(path, "wb") as buffer:
                    shutil.copyfileobj(f.file, buffer)
                image_url = f"/avatars/{filename}"
        
        elem_dict = elem_data.model_dump()
        elem_dict['image_url'] = image_url
        elem_dict['card_id'] = db_card.id

        db_element = EditableElement(**elem_dict)
        new_elements.append(db_element)

    # ---------- ФИКС: собираем список новых image_url ----------
    new_image_urls = {e.image_url for e in new_elements if e.image_url}

    # ---------- Удаляем старые элементы ----------
    for old_elem in list(db_card.elements):
        if old_elem.image_url:
            # удаляем только если файл не используется в новых элементах
            if old_elem.image_url not in new_image_urls:
                old_filename = os.path.basename(old_elem.image_url)
                old_image_path = os.path.join(AVATAR_DIR, old_filename)
                if os.path.exists(old_image_path):
                    try:
                        os.remove(old_image_path)
                    except OSError:
                        pass
        session.delete(old_elem)

    # ---------- Добавляем новые ----------
    session.add_all(new_elements)

    session.commit()
    session.refresh(db_card)
    return db_card


@router.delete("/{card_id}")
def delete_card(card_id: UUID, session: Session = Depends(get_session)):
    card = session.exec(select(Card).where(Card.id == card_id)).first()
    if card is None:
        raise HTTPException(status_code=404, detail="Card not found")
    
    session.delete(card)
    session.commit()
    return {"message": "Card deleted successfully"} 


@router.get("/{card_id}/qr-link", response_model=dict)
async def get_card_qr_link(card_id: UUID, session: Session = Depends(get_session)):
    
    card = session.exec(select(Card).where(Card.id == card_id)).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    # Формируем ссылку для QR-кода
    qr_link = f"https://connectcard.ru/users/{card_id}"
    return {"qr_link": qr_link}



@router.get("/{card_id}/analytics", response_model=dict)
async def get_card_analytics(
    card_id: UUID,
    start_date: Optional[datetime] = Query(None, description="Filter by start date"),
    end_date: Optional[datetime] = Query(None, description="Filter by end date"),
    session: Session = Depends(get_session)
):
    # Проверка существования карточки
    card = session.exec(select(Card).where(Card.id == card_id)).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")

    # Базовый запрос для аналитики
    base_query = select(Analytics).where(Analytics.card_id == card_id)
    if start_date:
        base_query = base_query.where(Analytics.view_timestamp >= start_date)
    if end_date:
        base_query = base_query.where(Analytics.view_timestamp <= end_date)

    # Общее количество просмотров
    total_views = session.exec(
        select(func.count())
        .select_from(Analytics)
        .where(Analytics.card_id == card_id)
        .where(Analytics.action_type == "view")
        .where(Analytics.view_timestamp >= start_date if start_date else True)
        .where(Analytics.view_timestamp <= end_date if end_date else True)
    ).one()

    # Количество репостов
    total_shares = session.exec(
        select(func.count())
        .select_from(Analytics)
        .where(Analytics.card_id == card_id)
        .where(Analytics.action_type == "share")
        .where(Analytics.view_timestamp >= start_date if start_date else True)
        .where(Analytics.view_timestamp <= end_date if end_date else True)
    ).one()

    # Количество добавлений в контакты
    total_add_to_contacts = session.exec(
        select(func.count())
        .select_from(Analytics)
        .where(Analytics.card_id == card_id)
        .where(Analytics.action_type == "add_to_contacts")
        .where(Analytics.view_timestamp >= start_date if start_date else True)
        .where(Analytics.view_timestamp <= end_date if end_date else True)
    ).one()

    # Конверсия (доля добавлений в контакты от просмотров)
    conversion_rate = (total_add_to_contacts / total_views * 100) if total_views > 0 else 0.0

    # Просмотры по типам устройств
    views_by_device = session.exec(
        select(Analytics.device_type, func.count())
        .where(Analytics.card_id == card_id)
        .where(Analytics.action_type == "view")
        .where(Analytics.view_timestamp >= start_date if start_date else True)
        .where(Analytics.view_timestamp <= end_date if end_date else True)
        .group_by(Analytics.device_type)
    ).all()

    # Популярные переходы по ссылкам
    link_clicks = session.exec(
        select(Analytics.link_widget_id, LinkWidget.name, func.count())
        .join(LinkWidget, Analytics.link_widget_id == LinkWidget.id, isouter=True)
        .where(Analytics.card_id == card_id)
        .where(Analytics.action_type == "link_click")
        .where(Analytics.view_timestamp >= start_date if start_date else True)
        .where(Analytics.view_timestamp <= end_date if end_date else True)
        .group_by(Analytics.link_widget_id, LinkWidget.name)
        .order_by(func.count().desc())
    ).all()

    # Топ действий
    actions_count = session.exec(
        select(Analytics.action_type, func.count())
        .where(Analytics.card_id == card_id)
        .where(Analytics.view_timestamp >= start_date if start_date else True)
        .where(Analytics.view_timestamp <= end_date if end_date else True)
        .group_by(Analytics.action_type)
        .order_by(func.count().desc())
    ).all()

    # Формирование ответа
    analytics_data = {
        "card_id": card_id,
        "total_views": total_views,
        "total_shares": total_shares,
        "total_add_to_contacts": total_add_to_contacts,
        "conversion_rate": round(conversion_rate, 2),  # В процентах, округлено до 2 знаков
        "views_by_device": {device_type: count for device_type, count in views_by_device},
        "popular_links": [
            {"link_widget_id": lid, "name": name, "clicks": count}
            for lid, name, count in link_clicks
            if lid is not None
        ],
        "top_actions": {action_type: count for action_type, count in actions_count}
    }
    # и вот так эта срань в ответет будет примерно выглядеть
    # {
    #   "card_id": 123,
    #   "total_views": 150,
    #   "total_shares": 10,
    #   "total_add_to_contacts": 5,
    #   "conversion_rate": 3.33,
    #   "views_by_device": {
    #     "desktop": 50,
    #     "mobile": 80,
    #     "tablet": 20
    #   },
    #   "popular_links": [
    #     {"link_widget_id": 1, "name": "LinkedIn", "clicks": 30},
    #     {"link_widget_id": 2, "name": "Telegram", "clicks": 15}
    #   ],
    #   "top_actions": {
    #     "view": 150,
    #     "link_click": 45,
    #     "share": 10,
    #     "add_to_contacts": 5
    #   }
    # }

    return analytics_data


@router.post("/{card_id}/action", response_model=dict)
async def record_action(card_id: UUID, action: ActionCreate, request: Request, session: Session = Depends(get_session)):
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