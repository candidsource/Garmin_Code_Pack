from fastapi import Depends, FastAPI
from contextlib import asynccontextmanager
from auth.db import User, create_db_and_tables
from auth.schemas import UserCreate, UserRead, UserUpdate
from auth.users import auth_backend, current_active_user, fastapi_users

import logging
from fastapi.routing import APIRoute

logger = logging.getLogger(__name__)



def list_routes(app: FastAPI):
    for route in app.routes:
        if isinstance(route, APIRoute):
            methods = ", ".join(route.methods)
            print(f"    {methods} -> {route.path}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Code to run on startup
    logger.info("INFO:     Starting up... and creating database tables...")
    # Not needed if you setup a migration system like Alembic
    await create_db_and_tables()
    list_routes(app)
    logger.info("INFO:     Startup complete.")
    yield
    # Code to run on shutdown (optional)
    logger.info("INFO:     Shutting down...")

app = FastAPI(lifespan=lifespan)
prefix = "/auth"
prefix = ""


app.include_router(
    fastapi_users.get_auth_router(auth_backend), prefix=f"{prefix}/jwt", tags=["auth"]
)
app.include_router(
    fastapi_users.get_register_router(UserRead, UserCreate),
    prefix=f"{prefix}",
    tags=["auth"],
)
app.include_router(
    fastapi_users.get_reset_password_router(),
    prefix=f"{prefix}",
    tags=["auth"],
)

app.include_router(
    fastapi_users.get_verify_router(UserRead),
    prefix=f"{prefix}",
    tags=["auth"],
)
app.include_router(
    fastapi_users.get_users_router(UserRead, UserUpdate),
    prefix="/users",
    tags=["users"],
)



@app.get("authenticated-route")
async def authenticated_route(user: User = Depends(current_active_user)):
    if user:
        return {"message": f"Welcome back, {user.email}!"}
    return {"message": "Hello, guest!"}


# current_active_user = fastapi_users.current_user(active=True)

@app.get("/protected-route")
def protected_route(user: User = Depends(current_active_user)):
    return f"Hello, {user.email}"



logger.info(f"current_active_user: {current_active_user}")


# @app.get("/protected-route")
# def protected_route(user: User = Depends(current_active_verified_user)):
#     return f"Hello, {user.email}"




    

