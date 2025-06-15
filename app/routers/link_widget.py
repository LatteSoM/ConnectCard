from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models.models import LinkWidget
from pydantic import BaseModel

router = APIRouter(
    prefix="/link-widgets",
    tags=["link-widgets"]
)

class LinkWidgetBase(BaseModel):
    link: str
    icon: str | None = None
    description: str | None = None
    name: str

class LinkWidgetCreate(LinkWidgetBase):
    pass

class LinkWidgetResponse(LinkWidgetBase):
    id: int

    class Config:
        from_attributes = True

@router.post("/", response_model=LinkWidgetResponse)
def create_link_widget(link_widget: LinkWidgetCreate, session: Session = Depends(get_session)):
    db_link_widget = LinkWidget(**link_widget.model_dump())
    session.add(db_link_widget)
    session.commit()
    session.refresh(db_link_widget)
    return db_link_widget

@router.get("/", response_model=List[LinkWidgetResponse])
def read_link_widgets(skip: int = 0, limit: int = 100, session: Session = Depends(get_session)):
    link_widgets = session.exec(select(LinkWidget).offset(skip).limit(limit)).all()
    return link_widgets

@router.get("/{link_widget_id}", response_model=LinkWidgetResponse)
def read_link_widget(link_widget_id: int, session: Session = Depends(get_session)):
    link_widget = session.exec(select(LinkWidget).where(LinkWidget.id == link_widget_id)).first()
    if link_widget is None:
        raise HTTPException(status_code=404, detail="Link widget not found")
    return link_widget

@router.put("/{link_widget_id}", response_model=LinkWidgetResponse)
def update_link_widget(link_widget_id: int, link_widget: LinkWidgetCreate, session: Session = Depends(get_session)):
    db_link_widget = session.exec(select(LinkWidget).where(LinkWidget.id == link_widget_id)).first()
    if db_link_widget is None:
        raise HTTPException(status_code=404, detail="Link widget not found")
    
    for key, value in link_widget.model_dump().items():
        setattr(db_link_widget, key, value)
    
    session.commit()
    session.refresh(db_link_widget)
    return db_link_widget

@router.delete("/{link_widget_id}")
def delete_link_widget(link_widget_id: int, session: Session = Depends(get_session)):
    link_widget = session.exec(select(LinkWidget).where(LinkWidget.id == link_widget_id)).first()
    if link_widget is None:
        raise HTTPException(status_code=404, detail="Link widget not found")
    
    session.delete(link_widget)
    session.commit()
    return {"message": "Link widget deleted successfully"} 