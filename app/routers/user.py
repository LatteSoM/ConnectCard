from fastapi import APIRouter, Depends, HTTPException, Request
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models.models import User, Card, ContactInfo, LinkWidget, CardContactInfo, CardLinkWidget, Analytics, AuditLog
from pydantic import BaseModel, EmailStr
from passlib.context import CryptContext
from ..database import engine
from user_agents import parse
from datetime import datetime
from ..encryption import encrypt_data, decrypt_data
from ..auth.auth import get_current_user

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class UserBase(BaseModel):
    avatar: str | None = None
    name: str
    phone: str | None = None
    email: EmailStr
    is_premium_user: bool = False
    telegram_authorized: bool = False
    vk_authorized: bool = False
    login: str

class UserCreate(UserBase):
    password: str
    consent_given: bool 

class UserUpdate(BaseModel):
    avatar: str | None = None
    name: str | None = None
    phone: str | None = None
    email: EmailStr | None = None
    login: str | None = None
    password: str | None = None 
    is_premium_user: bool | None = None
    telegram_authorized: bool | None = None
    vk_authorized: bool | None = None

class UserResponse(UserBase):
    id: int
    cards: List[Card]

    class Config:
        from_attributes = True

def get_password_hash(password: str):
    return pwd_context.hash(password)


@router.post("/", response_model=UserResponse)
async def create_user(user: UserCreate, session: Session = Depends(get_session)):
    if not user.consent_given:
        raise HTTPException(status_code=400, detail="Consent for personal data processing is required")
    
    if session.exec(select(User).where(User.email == encrypt_data(user.email))).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    if session.exec(select(User).where(User.login == user.login)).first():
        raise HTTPException(status_code=400, detail="Login already taken")
    
    hashed_password = get_password_hash(user.password)
    db_user = User(
        avatar=user.avatar,
        name=encrypt_data(user.name),
        phone=encrypt_data(user.phone) if user.phone else None,
        email=encrypt_data(user.email),
        is_premium_user=user.is_premium_user,
        telegram_authorized=user.telegram_authorized,
        vk_authorized=user.vk_authorized,
        login=user.login,
        password=hashed_password,
        consent_given=user.consent_given,
        consent_timestamp=datetime.utcnow() if user.consent_given else None,
        created_at=datetime.utcnow()
    )
    session.add(db_user)
    session.commit()
    session.refresh(db_user)

    # Логирование
    audit_log = AuditLog(
        user_id=db_user.id,
        action="create_user",
        details=f"Пользователь создан с email: {user.email}",
        timestamp=datetime.utcnow()
    )
    session.add(audit_log)
    session.commit()
    # Дешифрование данных для ответа
    db_user.name = decrypt_data(db_user.name)
    db_user.email = decrypt_data(db_user.email)
    db_user.phone = decrypt_data(db_user.phone) if db_user.phone else None
    return db_user

@router.get("/", response_model=List[UserResponse])
def read_users(skip: int = 0, limit: int = 100, session: Session = Depends(get_session)):
    users = session.exec(select(User).offset(skip).limit(limit)).all()
    return users

@router.get("/{user_id}", response_model=UserResponse)
async def read_user(
    user_id: int,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    if current_user.id != user_id and not current_user.is_premium_user:
        raise HTTPException(status_code=403, detail="Не авторизован для доступа к этому пользователю")
    user = session.exec(select(User).where(User.id == user_id)).first()
    if user is None:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    # Дешифрование данных для ответа
    user.name = decrypt_data(user.name)
    user.email = decrypt_data(user.email)
    user.phone = decrypt_data(user.phone) if user.phone else None
    return user

@router.put("/{user_id}", response_model=UserResponse)
def update_user(
    user_id: int,
    user: UserUpdate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):  
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Не авторизован для доступа к этому пользователю")
    db_user = session.exec(select(User).where(User.id == user_id)).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    
    # Проверка, не занят ли новый email или логин другого пользователя
    if user.email != db_user.email:
        if session.exec(select(User).where(User.email == user.email)).first():
            raise HTTPException(status_code=400, detail="Email уже зарегистрирован")
    if user.login != db_user.login:
        if session.exec(select(User).where(User.login == user.login)).first():
            raise HTTPException(status_code=400, detail="Логин уже занят")
    
    # Обновление полей пользователя
    update_data = user.model_dump(exclude={'password'})
    for key, value in update_data.items():
        if value is not None:
            if key in ['name', 'phone', 'email']:
                # Шифрование персональных данных
                setattr(db_user, key, encrypt_data(value) if value else None)
            else:
                setattr(db_user, key, value)
    
    # Обновление пароля, если он предоставлен
    if user.password:
        db_user.password = get_password_hash(user.password)

    db_user.updated_at = datetime.utcnow()
    
    audit_log = AuditLog(
        user_id=user_id,
        action="update_user",
        details=f"Пользователь обновлен: {user.model_dump_json(exclude={'password'})}",
        timestamp=datetime.utcnow()
    )
    session.add(audit_log)

    session.commit()
    session.refresh(db_user)
    
    db_user.name = decrypt_data(db_user.name)
    db_user.email = decrypt_data(db_user.email)
    db_user.phone = decrypt_data(db_user.phone) if db_user.phone else None
    
    return db_user

@router.delete("/{user_id}")
def delete_user(user_id: int, session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.id == user_id)).first()
    if user is None:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    
    audit_log = AuditLog(
        user_id=user_id,
        action="delete_user",
        details=f"Пользователь удален",
        timestamp=datetime.utcnow()
    )
    session.add(audit_log)
    session.commit()

    session.delete(user)
    session.commit()
    return {"message": "Пользователь успешно удален"} 


@router.get("/card/{card_id}", response_model=dict)
async def get_card_details(
    card_id: int, 
    request: Request, 
    session: Session = Depends(get_session),
):
    # if not current_user.is_premium_user:
    #     raise HTTPException(status_code=403, detail="Не авторизован для доступа к этой карточке")
    # Проверка существования карточки
    card = session.exec(select(Card).where(Card.id == card_id)).first()
    if not card:
        raise HTTPException(status_code=404, detail="Карточка не найдена")

    # Определение типа устройства из User-Agent
    user_agent_string = request.headers.get("user-agent", "")
    user_agent = parse(user_agent_string)
    device_type = "unknown"
    if user_agent.is_mobile:
        device_type = "mobile"
    elif user_agent.is_tablet:
        device_type = "tablet"
    elif user_agent.is_pc:
        device_type = "desktop"

    # Сохранение данных аналитики для просмотра
    analytics_entry = Analytics(
        card_id=card_id,
        device_type=device_type,
        action_type="view",
        user_agent=user_agent_string
    )
    session.add(analytics_entry)
    session.commit()

    # Получение связанных данных карточки
    contact_infos = session.exec(select(ContactInfo)
        .join(CardContactInfo)
        .where(CardContactInfo.card_id == card_id)).all()
    
    link_widgets = session.exec(select(LinkWidget)
        .join(CardLinkWidget)
        .where(CardLinkWidget.card_id == card_id)).all()

    # Формирование ответа
    card_data = {
        "id": card.id,
        "avatar": card.avatar,
        "fullname": card.fullname,
        "company": card.company,
        "position": card.position,
        "about": card.about,
        "contact_infos": [
            {"id": ci.id, "icon": ci.icon, "name": ci.name, "description": ci.description}
            for ci in contact_infos
        ],
        "link_widgets": [
            {"id": lw.id, "link": lw.link, "icon": lw.icon, "description": lw.description, "name": lw.name}
            for lw in link_widgets
        ]
    }
    
    return card_data

# Запрос на удаление данных пользователя
@router.post("/{user_id}/request-deletion")
async def request_deletion(
    user_id: int,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Не авторизован")
    user = session.exec(select(User).where(User.id == user_id)).first()
    if not user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    
    # Логирование запроса на удаление
    audit_log = AuditLog(
        user_id=user_id,
        action="request_deletion",
        details="Запрос на удаление данных пользователя",
        timestamp=datetime.utcnow()
    )
    session.add(audit_log)
    
    # Удаление данных
    session.delete(user)
    session.commit()
    return {"message": "Данные пользователя успешно удалены"}