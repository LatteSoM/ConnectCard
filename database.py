from sqlmodel import SQLModel, create_engine
from typing import Optional

DATABASE_URL = "postgresql+psycopg2://postgres:postgres@localhost:5432/apiDB"

engine = create_engine(DATABASE_URL, echo=True)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)