# email_utils.py
import logging
from pydantic import EmailStr

logger = logging.getLogger(__name__)

async def send_reset_password_email(email_to: EmailStr, token: str):
    """
    Dummy email sending function. In a real app, use fastapi-mail or similar.
    """
    reset_url = f"http://localhost:3000/reset-password?token={token}" # Example frontend URL
    subject = "Reset Your Password"
    body = f"""
    Hi,

    Someone requested a password reset for your account.
    If this was you, click the link below to reset your password:
    {reset_url}

    If you did not request this, please ignore this email.

    The token is: {token} (for testing purposes)
    """
    print("---- SENDING EMAIL (DUMMY) ----")
    print(f"To: {email_to}")
    print(f"Subject: {subject}")
    print(f"Body:\n{body}")
    print("-----------------------------")
    logger.info(f"Dummy email sent to {email_to} for password reset.")

async def send_verification_email(email_to: EmailStr, token: str):
    """
    Dummy email sending function for account verification.
    """
    verify_url = f"http://localhost:3000/verify-account?token={token}" # Example frontend URL
    subject = "Verify Your Account"
    body = f"""
    Hi,

    Thanks for signing up! Please verify your email address by clicking the link below:
    {verify_url}

    The token is: {token} (for testing purposes)
    """
    print("---- SENDING EMAIL (DUMMY) ----")
    print(f"To: {email_to}")
    print(f"Subject: {subject}")
    print(f"Body:\n{body}")
    print("-----------------------------")
    logger.info(f"Dummy verification email sent to {email_to}.")