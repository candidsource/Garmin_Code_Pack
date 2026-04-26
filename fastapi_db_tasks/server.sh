#! /bin/bash


BASE_DIR="/stage1/fastapi_db_tasks"
PYTHON_EXEC="/root/.pyenv/versions/3.13.2/envs/candid_3.13/bin/python3"

function launch_server() {
    cd "${BASE_DIR}" || { echo "Failed to change directory to ${BASE_DIR}"; exit 1; }
    "${PYTHON_EXEC}" -m uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4 
}



DAEMON_FILE="/etc/systemd/system/candid_source.service"
function config_server() {
    echo "
[Unit]
Description=Candid Source Dashboard
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=${BASE_DIR}
ExecStart=bash ${BASE_DIR}/server.sh
Restart=always

[Install]
WantedBy=multi-user.target" > "${DAEMON_FILE}"

    sudo systemctl daemon-reload
    sudo systemctl enable candid_source

}

if [[ ! -f "${DAEMON_FILE}" ]]; then
    config_server
fi

sudo systemctl start candid_source

launch_server

sudo systemctl status candid_source

# journalctl -u candid_source -f