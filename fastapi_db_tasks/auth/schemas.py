import uuid

from fastapi_users import schemas
from pydantic import BaseModel, EmailStr


class UserRead(schemas.BaseUser[uuid.UUID]):
    pass


class UserCreate(schemas.BaseUserCreate):
    # first_name: str
    # last_name: str
    pass


class UserUpdate(schemas.BaseUserUpdate):
    pass


class ForgotPasswordRequest(BaseModel):
    email: EmailStr
