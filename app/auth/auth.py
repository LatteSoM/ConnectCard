from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlmodel import Session, select
from datetime import timedelta
from typing import Optional
from ..dependencies import get_session
from ..models.models import User
from .utils import verify_password, get_password_hash, create_access_token, ACCESS_TOKEN_EXPIRE_MINUTES, SECRET_KEY, ALGORITHM
from pydantic import BaseModel
from jose import JWTError, jwt

router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class UserCreate(BaseModel):
    login: str
    password: str
    email: str
    name: str

async def get_current_user(token: str = Depends(oauth2_scheme), session: Session = Depends(get_session)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    
    user = session.exec(select(User).where(User.login == token_data.username)).first()
    if user is None:
        raise credentials_exception
    return user

@router.post("/register", response_model=Token)
def register(user_data: UserCreate, session: Session = Depends(get_session)):
    # Check if user already exists
    existing_user = session.exec(select(User).where(User.login == user_data.login)).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user_data.password)
    db_user = User(
        login=user_data.login,
        password=hashed_password,
        email=user_data.email,
        name=user_data.name
    )
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user_data.login}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/token", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.login == form_data.username)).first()
    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.login}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"} 


#Register a new User
# curl -X POST "http://localhost:8000/auth/register" \
#      -H "Content-Type: application/json" \
#      -d '{"login": "user1", "password": "password123", "email": "user1@example.com", "name": "User One"}'


#Login
# curl -X POST "http://localhost:8000/auth/token" \
#      -H "Content-Type: application/x-www-form-urlencoded" \
#      -d "username=user1&password=password123"

#Token
# curl -X GET "http://localhost:8000/protected-route" \
#      -H "Authorization: Bearer <your_token>"