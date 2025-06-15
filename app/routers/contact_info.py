from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.event import ContactInfo
from pydantic import BaseModel

router = APIRouter(
    prefix="/contact-info",
    tags=["contact-info"]
)

class ContactInfoBase(BaseModel):
    icon: str | None = None
    name: str
    description: str | None = None

class ContactInfoCreate(ContactInfoBase):
    pass

class ContactInfoResponse(ContactInfoBase):
    id: int

    class Config:
        from_attributes = True

@router.post("/", response_model=ContactInfoResponse)
def create_contact_info(contact_info: ContactInfoCreate, db: Session = Depends(get_db)):
    db_contact_info = ContactInfo(**contact_info.model_dump())
    db.add(db_contact_info)
    db.commit()
    db.refresh(db_contact_info)
    return db_contact_info

@router.get("/", response_model=List[ContactInfoResponse])
def read_contact_infos(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    contact_infos = db.query(ContactInfo).offset(skip).limit(limit).all()
    return contact_infos

@router.get("/{contact_info_id}", response_model=ContactInfoResponse)
def read_contact_info(contact_info_id: int, db: Session = Depends(get_db)):
    contact_info = db.query(ContactInfo).filter(ContactInfo.id == contact_info_id).first()
    if contact_info is None:
        raise HTTPException(status_code=404, detail="Contact info not found")
    return contact_info

@router.put("/{contact_info_id}", response_model=ContactInfoResponse)
def update_contact_info(contact_info_id: int, contact_info: ContactInfoCreate, db: Session = Depends(get_db)):
    db_contact_info = db.query(ContactInfo).filter(ContactInfo.id == contact_info_id).first()
    if db_contact_info is None:
        raise HTTPException(status_code=404, detail="Contact info not found")
    
    for key, value in contact_info.model_dump().items():
        setattr(db_contact_info, key, value)
    
    db.commit()
    db.refresh(db_contact_info)
    return db_contact_info

@router.delete("/{contact_info_id}")
def delete_contact_info(contact_info_id: int, db: Session = Depends(get_db)):
    contact_info = db.query(ContactInfo).filter(ContactInfo.id == contact_info_id).first()
    if contact_info is None:
        raise HTTPException(status_code=404, detail="Contact info not found")
    
    db.delete(contact_info)
    db.commit()
    return {"message": "Contact info deleted successfully"} 