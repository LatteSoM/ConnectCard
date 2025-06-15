from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.event import LinkWidget
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
def create_link_widget(link_widget: LinkWidgetCreate, db: Session = Depends(get_db)):
    db_link_widget = LinkWidget(**link_widget.model_dump())
    db.add(db_link_widget)
    db.commit()
    db.refresh(db_link_widget)
    return db_link_widget

@router.get("/", response_model=List[LinkWidgetResponse])
def read_link_widgets(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    link_widgets = db.query(LinkWidget).offset(skip).limit(limit).all()
    return link_widgets

@router.get("/{link_widget_id}", response_model=LinkWidgetResponse)
def read_link_widget(link_widget_id: int, db: Session = Depends(get_db)):
    link_widget = db.query(LinkWidget).filter(LinkWidget.id == link_widget_id).first()
    if link_widget is None:
        raise HTTPException(status_code=404, detail="Link widget not found")
    return link_widget

@router.put("/{link_widget_id}", response_model=LinkWidgetResponse)
def update_link_widget(link_widget_id: int, link_widget: LinkWidgetCreate, db: Session = Depends(get_db)):
    db_link_widget = db.query(LinkWidget).filter(LinkWidget.id == link_widget_id).first()
    if db_link_widget is None:
        raise HTTPException(status_code=404, detail="Link widget not found")
    
    for key, value in link_widget.model_dump().items():
        setattr(db_link_widget, key, value)
    
    db.commit()
    db.refresh(db_link_widget)
    return db_link_widget

@router.delete("/{link_widget_id}")
def delete_link_widget(link_widget_id: int, db: Session = Depends(get_db)):
    link_widget = db.query(LinkWidget).filter(LinkWidget.id == link_widget_id).first()
    if link_widget is None:
        raise HTTPException(status_code=404, detail="Link widget not found")
    
    db.delete(link_widget)
    db.commit()
    return {"message": "Link widget deleted successfully"} 