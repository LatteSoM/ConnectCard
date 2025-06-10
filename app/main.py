from fastapi import FastAPI
from routers.user_router import router as user_router
from routers.visitcard_router import router as visitcard_router

app = FastAPI()

app.include_router(user_router)
app.include_router(visitcard_router)