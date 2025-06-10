from sqlmodel import Session
from .config.settings import settings
from sqlalchemy import create_engine

engine = create_engine(settings.DATABASE_URL)

def get_session():
    with Session(engine) as session:
        yield session