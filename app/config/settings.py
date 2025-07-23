from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql://root:root@localhost:5432/test_db"


settings = Settings() 