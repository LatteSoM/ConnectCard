from fastapi import FastAPI
from app.routers import link_widget, contact_info, event, card, user, contact

app = FastAPI()

app.include_router(link_widget.router)
app.include_router(contact_info.router)
app.include_router(event.router)
app.include_router(card.router)
app.include_router(user.router)
app.include_router(contact.router)