from sqlmodel import Session, create_engine
from .config.settings import settings

engine = create_engine(settings.DATABASE_URL)

def get_db():
    with Session(engine) as session:
        yield session 