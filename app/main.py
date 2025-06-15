from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import card, contact_info, event, link_widget, user, contact
from .auth.auth import router as auth_router
from .database import create_db_and_tables

app = FastAPI(title="ConnectCard API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create database tables on startup
@app.on_event("startup")
def on_startup():
    create_db_and_tables()

# Include routers
app.include_router(auth_router)
app.include_router(card.router)
app.include_router(contact_info.router)
app.include_router(event.router)
app.include_router(link_widget.router)
app.include_router(user.router)
app.include_router(contact.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to ConnectCard API"}