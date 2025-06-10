from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import Annotated
from uuid import UUID
from ..models.user import User
from ..dependencies import get_session

router = APIRouter(
    prefix="/users",
    tags=["Пользователи"]
)

@router.post("/")
async def create_user(user: User, session: Annotated[Session, Depends(get_session)]):
    db_user = User(**user.dict(exclude_unset=True))
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

@router.get("/")
async def read_users(session: Annotated[Session, Depends(get_session)]):
    users = session.exec(select(User)).all()
    return users

@router.get("/{user_id}")
async def read_user(user_id: UUID, session: Annotated[Session, Depends(get_session)]):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    return user

@router.put("/{user_id}")
async def update_user(user_id: UUID, user: User, session: Annotated[Session, Depends(get_session)]):
    db_user = session.get(User, user_id)
    if not db_user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    user_data = user.dict(exclude_unset=True)
    for key, value in user_data.items():
        setattr(db_user, key, value)
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

@router.delete("/{user_id}")
async def delete_user(user_id: UUID, session: Annotated[Session, Depends(get_session)]):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    session.delete(user)
    session.commit()
    return {"message": "Пользователь удалён"}