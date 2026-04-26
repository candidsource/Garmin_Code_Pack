import json
import logging
import os
import platform
import re
import subprocess
from collections import OrderedDict
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Annotated, Any, Dict, Optional
from functools import lru_cache

import httpx

# Function to print all routes
from auth.app import app as auth
from auth.app import list_routes
from auth.db import User
from auth.users import current_active_user, custom_user_db_actions, is_super_user
from fastapi import Body, Depends, FastAPI, Form, HTTPException, Request, Response
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, EmailStr
from pydantic_settings import BaseSettings, SettingsConfigDict

# class PatchAdopPayload(BaseModel):
#     fs_clone: Optional[Dict] = None
#     prepare: Optional[Dict] = None
#     apply: Optional[Dict] = None
#     cutover: Optional[Dict] = None
#     finalize: Optional[Dict] = None


class Item(BaseModel):
    SYSPWD: str | None = None
    WLS_PWD: str | None = None
    APPS_PWD: str | None = None
    SYS_PWD: str | None = None
    ISG_PWD: str | None = None
    EBS_SYSTEM_PWD: str | None = None
    t_APPS_PWD: str | None = None
    SYSTEM_PWD: str | None = None
    t_SYSADMIN_PWD: str | None = None
    t_ASADMIN_PWD: str | None = None
    t_APEX_USER: str | None = None
    t_APEX_EMAIL: str | None = None


class Credentials(BaseModel):
    USER: str | None = None
    PASS: str | None = None


class Dbtasks(str, Enum):
    clone = "clone"
    backup = "backup"


class Settings(BaseSettings):
    EBS: str = ""
    model_config = SettingsConfigDict(env_file=".env")

@lru_cache
def get_settings():
    return Settings()


# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

uvicorn_logger = logging.getLogger("uvicorn.error")
uvicorn_logger.name = "uvicorn"

PORT = os.getenv("PORT", "8443")
PROTOCOL = "HTTPS" if PORT == "8443" else "HTTP"

# Initialize FastAPI app
app = FastAPI()
app.mount("/auth", auth)


app.state.db_creds = {}

app_dir = Path(__file__).parent

BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "static/webpages"
IMAGE_DIR = BASE_DIR / "static/images"
JS_DIR = BASE_DIR / "static/js"

# Serve static files (CSS, JS, etc.)
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")
app.mount("/images", StaticFiles(directory=IMAGE_DIR), name="images")
app.mount("/js", StaticFiles(directory=JS_DIR), name="js")

def set_env_vars(env_name: str):
    settings = get_settings()
    os.environ["SCRIPT_PATH"] = f"{os.environ['EBS']}/{env_name.upper()}"


# @app.get("/", response_class=FileResponse)
# async def first_page_page():
#     try:
#         return serve_html()
#     except Exception:
#         return FileResponse(STATIC_DIR / "login.html")

# async def serve_html(current_user: Annotated[User, Depends(current_active_user)]):
#     return FileResponse(STATIC_DIR / "tasks.html")


# Endpoint to serve the HTML file
@app.get("/", response_class=FileResponse)
async def serve_html():
    return FileResponse(STATIC_DIR / "tasks.html")


@app.get("/users.html", response_class=FileResponse)
async def users_management():
    return FileResponse(STATIC_DIR / "users.html")


@app.get("/images/{image}", response_class=FileResponse)
async def serve_image(image: str):
    return FileResponse(IMAGE_DIR / image)


@app.get("/configs/tasks")
@app.get("/tasks/list")
async def get_tasks():
    with open(app_dir / "configs" / "config.json") as fr:
        tasks = json.load(fr)
    tasks["extras"] = {"node": platform.node}
    return tasks


@app.get("/configs/dbconfig")
async def get_db_config_format():
    config: OrderedDict[str, str] = OrderedDict()
    with open(app_dir / "configs" / "creds.json") as fr:
        config = json.load(fr)
    return config


@app.get("/configs/prechecks")
async def get_prechecks():
    prechecks = {}
    with open(app_dir / "configs" / "pre_checks.json") as fr:
        prechecks = json.load(fr)
    return prechecks


@app.post("/configs/prechecks")
async def update_prechecks(request: Request, current_user: Annotated[User, Depends(current_active_user)]):
    prechecks = {}
    with open(app_dir / "configs" / "pre_checks.json") as fr:
        prechecks = json.load(fr)

    data = await request.json()
    task_type = data.get("task_type")
    checklist_key = data.get("checklist_key")
    completed = data.get("completed")

    if task_type in prechecks and checklist_key in prechecks[task_type]:
        temp_dict: dict[str, str] = {
            "completed": completed,
            "completed_by": current_user.email,
            "completed_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "notes": "",
        }
        prechecks[task_type][checklist_key]["data"].append(temp_dict)

        with open(app_dir / "configs" / "pre_checks.json", "w") as fw:
            json.dump(prechecks, fw, indent=4)
    return {"status": "success"}


@app.get("/logs")
async def get_logs(
    task_type: str, task_segment: str, task: str, env: str = "", file_name: str = "", lines: str = ""
) -> dict[str, str | dict[str, str]]:
    if env == "":
        logger.info("No env selected")
        return {"error": "Need Environment"}

    log_line_type = ""
    set_env_vars(env)

    script_path = app_dir / "scripts" / "clone.sh"

    logger.info(f"script path: {script_path!s}, task name: {task}")
    # Check if the script exists and is executable
    if not script_path.exists():
        logger.error(f"FILE DOES NOT EXIST: {script_path!s}")
        raise HTTPException(status_code=404, detail=f"Script :'{script_path!s}': not found.")
    if not script_path.is_file():
        logger.error(f"IS NOT A FILE: {script_path!s}")
        raise HTTPException(status_code=400, detail=f"'{script_path}' is not a valid script.")
    if not script_path.stat().st_mode & 0o111:
        logger.error(f"FILE IS NOT EXECUTABLE: {script_path!s}")
        raise HTTPException(status_code=403, detail=f"Script '{script_path!s}' is not executable.")

    cmd_list = []
    try:
        # Execute the script and capture output
        logger.info(f"env: {env}, task: {task}, file_name: {file_name}, lines: {lines}")
        task_status: dict[str, Any] = get_task_status(env)
        if file_name == "":
            log_lines = ""
            log_line_type = "file name not passed"
        elif lines != "":
            try:
                log_lines = int(lines)
                log_line_type = "url_param"
            except Exception:
                log_lines = 1
                log_line_type = "invalid url_param"
        else:
            log_lines = 1
            log_line_type = "default"

        script_path = app_dir / "scripts" / "read_logs.sh"
        cmd_list = ["bash", str(script_path), env, task_type, task_segment, task, file_name, str(log_lines)]

        result = subprocess.run(
            cmd_list,  # Convert Path to string
            capture_output=True,
            text=True,  # Get output as a string
            check=True,  # Raise CalledProcessError for non-zero exit codes
        )
        if result.stdout.startswith("ERROR:"):
            return {"status": "error", "output": "", "error": result.stdout, "logs_task_status": task_status}
        actual_output = result.stdout.split("READ_LOGS_OUTPUT")[-1].strip()
        if file_name and actual_output.strip():
            matches = re.search(r"(\d+)", actual_output.strip())
            if matches:
                actual_output = re.sub(rf".*?{file_name}\n*", "", actual_output, re.DOTALL | re.MULTILINE)

        return {
            "status": "success",
            "output": actual_output,
            "lines": str(log_lines),
            "log_line_type": log_line_type,
            "error": result.stderr,
            "logs_task_status": task_status,
        }
    except subprocess.CalledProcessError as e:
        # Handle script execution errors
        raise HTTPException(
            status_code=500, detail=f"Log Script '{script_path}' failed with exit code {e.returncode}: {e!s}"
        ) from e
    except Exception as e:
        # Catch any other unexpected errors
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred: {e!s}") from e


@app.post("/configs/dbconfig")
async def set_db_config(config: Item) -> dict[str, str]:
    result = {**config.model_dump()}
    app.state.db_creds = result
    return result


# @app.get("/configs/dbconf")
# used to verify ui params
# async def get_db_config():
#     return app.state.db_creds


@app.get("/tasks/{task}")
async def get_subtask(task: Dbtasks):
    config_path = app_dir / "configs" / "config.json"
    try:
        with open(config_path) as fr:
            tasks = json.load(fr)

        logger.info("Tasks json loaded successfully.")
        if task.value not in tasks:
            logger.error(f"Task '{task.value}' not found in configuration. ")
            raise HTTPException(status_code=404, detail=f"Task: {task.value}, not found")

        return tasks[task.value]

    except FileNotFoundError:
        logger.exception(f"Configuration file not found at {config_path}.")
        raise HTTPException(status_code=500, detail="Configuration file not found.")
    except json.JSONDecodeError:
        logger.exception(f"Invalid JSON format in {config_path}.")
        raise HTTPException(status_code=500, detail="Invalid configuration format.")
    except Exception as err:
        raise HTTPException(status_code=500, detail=str(err)) from err


@app.get("/resume")
async def resume_script(env: str, task_type: str, task_segment: str, task: str):
    if env == "":
        logger.info("No env selected")
        return {
            "error": "Need Environment",
            "env": env,
            "task_type": task_type,
            "task": task,
            "task_segment": task_segment,
        }

    logger.info(f"resume task: {task_type} {task}")
    return await execute_script(task_type, task_segment, task, "resume", env)


@app.post("/run/{task_type}")
async def execute_script_adop(
    task_type: str, payload: dict[str, str | dict[str, str]] = Body(...), user: User = Depends(current_active_user)
):
    logger.info(f"received request: {task_type}")
    logger.info(f"payload: {payload!s}")

    task_segment: str = payload.get("task_segment", "")
    task_name: str = payload.get("task", "")
    env: str = payload.get("env", "")

    if env == "":
        logger.info("No env selected")
        return {"error": "Need Environment"}
    set_env_vars(env)

    script_path = app_dir / "scripts" / "clone.sh"
    check_file(script_path)

    running_already = check_if_running_already(env, task_type, task_segment, task_name)
    if running_already is not None:
        logger.info("execute script exitting, task already running")
        logger.info(running_already)
        return {"status": "failed", "output": running_already["output"], "error": str(running_already)}

    csv_args = ""
    for step_name, step_config in payload.items():
        if not step_name.startswith("task__"):
            continue
        csv_args = f"{csv_args}####{step_name.split('task__')[1]},{step_config}"

    csv_args = re.sub(r"^####|####$", "", csv_args)
    logger.info(f"CSV args: {csv_args}")
    if csv_args == "":
        logger.info("No args passed, setting to 'none'")
        return {
            "status": "no params",
            "output": "Missing params, kindly pass args",
            "error": "",
            "payload": str(payload),
        }

    try:
        # Execute the script and capture output
        logger.info(f"executing script for task:{task_type}")
        result = subprocess.run(
            ["bash", str(script_path), env, task_type, task_segment, f"{csv_args}"],  # Convert Path to string
            stdout=None,
            stderr=None,
            text=True,  # Get output as a string
            check=True,  # Raise CalledProcessError for non-zero exit codes
        )
        return {
            "status": "success",
            "output": "Job Submitted, Kindly check logs for more info",
            "error": str(result.stderr),
        }
    except subprocess.CalledProcessError as e:
        # Handle script execution errors
        raise HTTPException(status_code=500, detail=f"Script '{task_type}' failed with exit code {e.returncode}: {e!s}")
    except Exception as e:
        # Catch any other unexpected errors
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred: {str(e)}")


def check_file(script_path: Path | str) -> None:
    if isinstance(script_path, str):
        script_path = Path(script_path)

    # Check if the script exists and is executable
    if not script_path.exists():
        logger.error(f"FILE DOES NOT EXIST: {str(script_path)}")
        raise HTTPException(status_code=404, detail=f"Script :'{str(script_path)}': not found.")
    if not script_path.is_file():
        logger.error(f"IS NOT A FILE: {str(script_path)}")
        raise HTTPException(status_code=400, detail=f"'{script_path}' is not a valid script.")
    if not script_path.stat().st_mode & 0o111:
        logger.error(f"FILE IS NOT EXECUTABLE: {str(script_path)}")
        raise HTTPException(status_code=403, detail=f"Script '{str(script_path)}' is not executable.")


def check_if_running_already(env: str, task_type: str, task_segment: str, task: str = "") -> dict[str, str] | None:
    # check if script running already
    set_env_vars(env)
    logger.info("Check if script is running already")
    script_path = app_dir / "scripts" / "clone.sh"
    logger.info(f"bash {str(script_path)} {env} {task_type}-{task_segment} status")
    # status_command = f"bash {str(script_path)} {env} {task_type}_{task} status"

    result = subprocess.run(
        ["bash", str(script_path), env, task_type, task_segment, task, "status"],  # Convert Path to string
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,  # Get output as a string
        check=True,  # Raise CalledProcessError for non-zero exit codes
    )

    if "already running" in result.stdout:
        running_task_name = re.findall(r"already running:\s*(.+)", result.stdout)
        logger.info(f"already running found in status: {running_task_name!s}")

        if running_task_name:
            running_task_name = running_task_name[0]
            running_task_name = running_task_name.split(r"\n")[0]
            running_task_name = re.sub(r"\\", "", running_task_name)
        else:
            running_task_name = "A task"
        return {"output": f"{running_task_name} is already running"}
    elif result.stderr:
        return {"output": f"ERROR: {result.stderr}"}
    else:
        logger.info(f"script running status stdout: {result.stdout}")
        logger.info(f"script running status stderr: {result.stderr}")


@app.get("/run")
async def execute_script(
    task_type: str,
    task_segment: str,
    task: str,
    resume: Optional[str] = "",
    env: str = "",
    user: User = Depends(current_active_user),
):
    """
    Executes a shell script located in the server's script directory.
    """
    if env == "":
        logger.info("No env selected")
        return {"error": "Need Environment"}
    set_env_vars(env)

    # for key in app.state.db_creds:
    #     os.environ[key] = app.state.db_creds[key]

    script_path = app_dir / "scripts" / "clone.sh"
    check_file(script_path)

    logger.info(f"script path: {str(script_path)}")

    # try:
    running_already = check_if_running_already(env, task_type, task_segment, task)
    if running_already is not None:
        logger.info("execute script exitting, task already running")
        logger.info(running_already)
        return {"status": "failed", "output": running_already["output"], "error": str(running_already)}
    else:
        logger.info("no running task found, proceeding to execute script")

    # Execute the script and capture output
    logger.info(f"executing script for task:{task_type}:{task}")
    cmd_list = ["bash", str(script_path), env, task_type, task_segment, task, f"{resume}".lower()]
    result = subprocess.run(
        cmd_list,  # Convert Path to string
        stdout=None,
        stderr=None,
        text=True,  # Get output as a string
        check=True,  # Raise CalledProcessError for non-zero exit codes
    )
    return {"status": "success", "output": "Job Submitted, Kindly check logs for more info", "error": result.stderr}
    # except subprocess.CalledProcessError as e:
    #     # Handle script execution errors
    #     raise HTTPException(
    #         status_code=500,
    #         detail=f"Script '{task_type}_{task}' failed with exit code {e.returncode}: {e!s}",
    #     )
    # except Exception as e:
    #     # Catch any other unexpected errors
    #     raise HTTPException(
    #         status_code=500,
    #         detail=f"An unexpected error occurred: {str(e)}",
    #         running_already=str(running_already),
    #     )


def get_task_status(env: str = "") -> dict[str, str | dict[str, str]]:
    set_env_vars(env)
    script_path = app_dir / "scripts" / "clone.sh"
    task_status_resp: dict[str, str] = {}
    # Execute the script and capture output
    logger.info("checking task status")
    result = subprocess.run(
        ["bash", str(script_path), env, "task-status"],  # Convert Path to string
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,  # Get output as a string
        check=True,  # Raise CalledProcessError for non-zero exit codes
    )
    task_status_resp = {"status": "success", "output": result.stdout, "error": result.stderr}
    logger.info("status script executed successfully, check if status file exists")

    status_file = re.findall(r"Latest task status file:\s*([^\n]+)", task_status_resp["output"])
    if not status_file:
        logger.info(f"status file not found in output: {task_status_resp['output']}")
        return {
            "status_file": str(status_file),
            "output": task_status_resp["output"],
            "message": task_status_resp["output"],
        }

    status_file = status_file[0].strip()
    logger.info(f"status file found: {status_file}")
    task_status: dict = {}
    with open(status_file) as fr:
        for line in fr.readlines():
            line = line.strip().split(",")

            task_type = line[2]
            task_segment = line[3]
            task_status[task_type] = task_status.get(task_type, {})
            task_status[task_type][task_segment] = task_status[task_type].get(task_segment, {})

            task_status[task_type][task_segment][line[-2]] = {"status": line[-1], "start": line[0], "end": line[1]}

    return {"status": json.dumps(task_status)}


@app.get("/status")
async def get_status(env: str = "") -> dict[str, str | dict[str, str]]:
    if env == "":
        logger.info("No env selected")
        return {"error": "Need Environment"}
    set_env_vars(env)

    task_status_resp: dict[str, str | dict[str, str]] = {}
    try:
        task_status_resp = get_task_status(env)
    except subprocess.CalledProcessError as e:
        # Handle script execution errors
        raise HTTPException(status_code=500, detail=f"Status Script failed with exit code {e.returncode}: {e!s}")
    except Exception as e:
        # Catch any other unexpected errors
        logger.error(f"An unexpected error occurred: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred")

    return task_status_resp


@app.get("/users/all")
async def list_users(current_user: Annotated[User, Depends(is_super_user)]):
    # return JSONResponse(content={"status": "success", "message": "User list fetched successfully"})
    try:
        return await custom_user_db_actions()
    except Exception as e:
        logger.error(f"Error fetching users: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {e}")


@app.get("/users/me")
async def read_users_me(current_user: Annotated[User, Depends(current_active_user)]) -> JSONResponse:
    return JSONResponse(
        content={
            "status": "success",
            "id": str(current_user.id),
            "email": current_user.email,
            # "name": current_user.first_name,
            "is_active": current_user.is_active,
            "is_superuser": current_user.is_superuser,
            "is_verified": current_user.is_verified,
        }
    )


async def login_user(username: str, password: str) -> dict[str, str]:
    async with httpx.AsyncClient(verify=False) as client:
        response = await client.post(
            f"{PROTOCOL}://localhost:{PORT}/auth/jwt/login",
            data={"username": username, "password": password},
            headers={"Content-Type": "application/x-www-form-urlencoded"},
        )
        response.raise_for_status()
        return response.json()  # This will return access_token and token_type
        # return {"username": username, "password": password, "access_token": "dummy_token", "token_type": "bearer"}


@app.post("/login")
async def handle_login(
    response: Response, username: str = Form(..., alias="username"), password: str = Form(..., alias="password")
) -> JSONResponse:
    """
    Handles the login request sent from the jQuery frontend.
    Receives 'USER' and 'PASS' as form data.
    """
    logger.info(f"Received login attempt for user: {username}")  # Optional: for debugging

    # # --- Authentication Logic Here ---
    user_login = await login_user(username, password)
    # # --- End Authentication Logic ---
    if "access_token" in user_login:
        content: dict[str, str] = {
            "status": "success",
            "message": "Login successful",
            "token_type": user_login.get("token_type", "bearer"),
        }

        # Create the JSON response first
        response = JSONResponse(content=content)

        # Set the cookie on the response object itself
        response.set_cookie(
            key="access_token",
            value=user_login["access_token"],
            httponly=True,
            secure=False,  # Set True in production with HTTPS
            samesite="strict",
            max_age=600,
            path="/",
        )
        return response
    else:
        return JSONResponse(content={"status": "error", "message": "Invalid User ID or Password"})


async def get_forgot_pass_token(username: str, password: str) -> dict[str, str]:
    async with httpx.AsyncClient(verify=False) as client:
        response = await client.post(
            f"{PROTOCOL}://localhost:{PORT}/auth/forgot-password",
            data={"username": username, "password": password},
            headers={"Content-Type": "application/x-www-form-urlencoded"},
        )
        response.raise_for_status()
        return response.json()  # This will return access_token and token_type
        # return {"username": username, "password": password, "access_token": "dummy_token", "token_type": "bearer"}


async def reset_password_auth(username: str, password: str, old_pass: str) -> dict[str, str]:
    logger.info("reset pass function called")
    forgot_pass_token = await get_forgot_pass_token(username, old_pass)
    logger.info(f"forgot_pass_token: {forgot_pass_token!s}")
    return forgot_pass_token

    # async with httpx.AsyncClient(verify=False) as client:
    #     response = await client.post(
    #         f"{PROTOCOL}://localhost:{PORT}/auth/reset-password",
    #         data={"username": username, "password": password},
    #         headers={"Content-Type": "application/x-www-form-urlencoded"},
    #     )
    #     response.raise_for_status()
    #     return response.json()  # This will return access_token and token_type
    #     # return {"username": username, "password": password, "access_token": "dummy_token", "token_type": "bearer"}


@app.post("/reset-pass")
async def reset_password(
    response: Response,
    current_user: Annotated[User, Depends(current_active_user)],
    old_pass: str = Form(..., alias="old_password"),
    new_pass: str = Form(..., alias="new_password"),
) -> JSONResponse:
    """
    Handles the login request sent from the jQuery frontend.
    Receives 'USER' and 'PASS' as form data.
    """
    username = current_user.email
    logger.info(f"Received login attempt for user: {username}")  # Optional: for debugging

    # # --- Authentication Logic Here ---
    reset_pass_resp = await reset_password_auth(username, new_pass, old_pass)
    # # --- End Authentication Logic ---
    if "access_token" in reset_pass_resp:
        content: dict[str, str] = {
            "status": "success",
            "message": "Login successful",
            "token_type": reset_pass_resp.get("token_type", "bearer"),
        }

        # Create the JSON response first
        response = JSONResponse(content=content)

        # Set the cookie on the response object itself
        response.set_cookie(
            key="access_token",
            value="access_token",
            httponly=True,
            secure=False,  # Set True in production with HTTPS
            samesite="strict",
            max_age=3600,
            path="/",
        )
        return response
    else:
        return JSONResponse(content={"status": "error", "message": "Invalid User ID or Password"})


async def logout_user():
    async with httpx.AsyncClient(verify=False) as client:
        response = await client.post(
            f"{PROTOCOL}://localhost:{PORT}/auth/jwt/logout",
            data={"username": current_active_user},
            headers={"Content-Type": "application/x-www-form-urlencoded"},
        )
        response.raise_for_status()
        return response.json()  # This will return access_token and token_type
        # return {"username": username, "password": password, "access_token": "dummy_token", "token_type": "bearer"}


@app.post("/logout")
async def loggout(response: Response, username: str = Form(..., alias="username")) -> JSONResponse:
    """
    Handles the login request sent from the jQuery frontend.
    Receives 'USER' and 'PASS' as form data.
    """
    logger.info("Received logout attempt")
    # await logout_user() # need to invalidate the token in the backend

    try:
        content: dict[str, str] = {"status": "success", "message": "LogOut successful"}

        # Create the JSON response first
        response = JSONResponse(content=content)

        # Set the cookie on the response object itself
        response.delete_cookie(key="access_token", path="/")
        return response
    except Exception as e:
        logger.error(f"Error clearing cookie during logout: {e}", exc_info=True)
        # Even if cookie deletion fails somehow, maybe still proceed? Or return error.
        # Depending on requirements, you might still return success,
        # or indicate a partial failure.
        # For robustness, let's return an error if deletion fails.
        return JSONResponse(
            status_code=500, content={"status": "error", "message": "Logout failed during cookie clearing."}
        )


@app.post("/trigger-forgot-password-for-user", tags=["testing"])
async def trigger_forgot_password(user: User = Depends(current_active_user)):
    """
    A helper endpoint to simulate initiating a forgot password request.
    In a real app, your frontend would POST directly to /auth/forgot-password.
    """
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # The actual logic is handled by fastapi_users.get_reset_password_router()
    # This endpoint just confirms the user exists and then you'd tell the client
    # to call /auth/forgot-password
    # Or, for a more direct test, we could simulate the request here,
    # but it's better to test the actual /auth/forgot-password endpoint.

    # To actually trigger it (if you were proxying for some reason):
    # from httpx import AsyncClient
    email = """
    """

    async with httpx.AsyncClient(base_url=f"{PROTOCOL}://127.0.0.1:{PORT}") as client:
        response = await client.post("/auth/forgot-password", json={"email": email})
        if response.status_code == 202:  # Accepted
            return {"message": f"Forgot password request sent for {email}. Check console for dummy email."}
        else:
            raise HTTPException(status_code=response.status_code, detail=response.json().get("detail"))
    return {"message": f"User {email} exists. Frontend should now POST to /auth/forgot-password with this email."}


list_routes(app)
list_routes(auth)
