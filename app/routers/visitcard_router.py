from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import Annotated
from uuid import UUID
from ..models.visitcard import VisitCard
from ..models.user import User
from ..dependencies import get_session

router = APIRouter(
    prefix="/visit-cards",
    tags=["Визитные карты"]
)

@router.post("/")
async def create_visit_card(visit_card: VisitCard, session: Annotated[Session, Depends(get_session)]):
    db_user = session.get(User, visit_card.user_id)
    if not db_user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    db_visit_card = VisitCard(**visit_card.dict(exclude_unset=True))
    session.add(db_visit_card)
    session.commit()
    session.refresh(db_visit_card)
    return db_visit_card

@router.get("/")
async def read_visit_cards(session: Annotated[Session, Depends(get_session)]):
    visit_cards = session.exec(select(VisitCard)).all()
    return visit_cards

@router.get("/{visit_card_id}")
async def read_visit_card(visit_card_id: UUID, session: Annotated[Session, Depends(get_session)]):
    visit_card = session.get(VisitCard, visit_card_id)
    if not visit_card:
        raise HTTPException(status_code=404, detail="Визитная карта не найдена")
    return visit_card

@router.put("/{visit_card_id}")
async def update_visit_card(visit_card_id: UUID, visit_card: VisitCard, session: Annotated[Session, Depends(get_session)]):
    db_visit_card = session.get(VisitCard, visit_card_id)
    if not db_visit_card:
        raise HTTPException(status_code=404, detail="Визитная карта не найдена")
    visit_card_data = visit_card.dict(exclude_unset=True)
    for key, value in visit_card_data.items():
        setattr(db_visit_card, key, value)
    session.add(db_visit_card)
    session.commit()
    session.refresh(db_visit_card)
    return db_visit_card

@router.delete("/{visit_card_id}")
async def delete_visit_card(visit_card_id: UUID, session: Annotated[Session, Depends(get_session)]):
    visit_card = session.get(VisitCard, visit_card_id)
    if not visit_card:
        raise HTTPException(status_code=404, detail="Визитная карта не найдена")
    session.delete(visit_card)
    session.commit()
    return {"message": "Визитная карта удалена"}