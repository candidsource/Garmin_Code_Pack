import uuid
# Need AsyncGenerator for the get_user_manager return type
from typing import Optional, AsyncGenerator, Any

from fastapi import Depends, Request
from fastapi_users import BaseUserManager, FastAPIUsers, UUIDIDMixin
from fastapi_users.db import SQLAlchemyUserDatabase
from .email_utils import send_reset_password_email, send_verification_email # Import dummy email sender

from pydantic import EmailStr

from fastapi_users.authentication import (
    AuthenticationBackend,
    BearerTransport,
    JWTStrategy,
    CookieTransport
)

# Assuming these are correctly defined and imported
from auth.db import User, get_user_db

SECRET = "SECRET"  # Make sure this is loaded securely in a real app


class UserManager(UUIDIDMixin, BaseUserManager[User, uuid.UUID]):
    reset_password_token_secret = SECRET
    verification_token_secret = SECRET
    email: EmailStr

    async def on_after_register(self, user: User, request: Optional[Request] = None):
        print(f"User {user.id} has registered.")

    async def on_after_forgot_password(
        self, user: User, token: str, request: Optional[Request] = None
    ):
        print(f"User {user.id} has requested a password reset. Token: {token}")
        # Send email with the token
        await send_reset_password_email(user.email, token)

    async def on_after_request_verify(
        self, user: User, token: str, request: Optional[Request] = None
    ):
        print(f"Verification requested for user {user.id}. Verification token: {token}")
        
    async def get_all_users(
        self
    ):
        
        return self.user_db.get(id= uuid.UUID("9f39717d-b4b0-456a-9fa5-8f173d3e2761"))
    
        

# Fix 1: Specify the generic types for SQLAlchemyUserDatabase
# Fix 2: Specify the correct return type for the async generator
async def get_user_manager(
    user_db: SQLAlchemyUserDatabase[User, uuid.UUID] = Depends(get_user_db) # Fix 1
) -> AsyncGenerator[UserManager, None]: # Fix 2 (Yields UserManager, finishes)
    yield UserManager(user_db)
    
    


async def custom_user_db_actions(
    user_db: SQLAlchemyUserDatabase[User, uuid.UUID] = Depends(get_user_db) # Fix 1
):
    # return {"status": "work in progress"}
    user_manager = UserManager(user_db)
    content: dict[str, Any] = {"user_manager": dir(user_manager)}
    content["get_all_users"] = await user_manager.get_all_users()
    return content


bearer_transport = BearerTransport(tokenUrl="auth/jwt/login")
cookie_transport = CookieTransport(
    cookie_name="access_token",
    cookie_max_age=3600,
    cookie_httponly=True,  # This makes it HttpOnly
    cookie_samesite="strict"
)


# Fix 3: Specify the generic types for the JWTStrategy return type
def get_jwt_strategy() -> JWTStrategy[User, uuid.UUID]: # Fix 3
    return JWTStrategy(secret=SECRET, lifetime_seconds=3600)


# Fix 4: Specify the generic types for AuthenticationBackend (explicitly)
auth_backend: AuthenticationBackend[User, uuid.UUID] = AuthenticationBackend( # Fix 4
    name="jwt",
    transport=bearer_transport,
    get_strategy=get_jwt_strategy, # This function now returns the correctly typed strategy
)
jwt_backend = AuthenticationBackend(
    name="jwt",
    transport=bearer_transport,
    get_strategy=get_jwt_strategy,
)
cookie_backend = AuthenticationBackend(
    name="jwt",
    transport=cookie_transport,
    get_strategy=get_jwt_strategy,
)


# This line should now be correct because its arguments are correctly typed
fastapi_users = FastAPIUsers[User, uuid.UUID](
    get_user_manager, # Return type is now correct
    [cookie_backend]
)

# async def get_enabled_backends(request: Request):
#     """Return the enabled dependencies following custom logic."""
#     if request.url.path == "/protected-route-only-jwt":
#         return [jwt_backend]
#     else:
#         return [cookie_backend, jwt_backend]

current_active_user = fastapi_users.current_user(active=True)
is_super_user = fastapi_users.current_user(active=True, superuser=True)
# current_active_user = fastapi_users.current_user(active=True, get_enabled_backends=get_enabled_backends)
