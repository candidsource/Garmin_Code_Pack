# git will be required to clone the repository and install pyenv 
sudo yum install openssl-devel
sud yum install git

# install pyenv 
curl -fsSL https://pyenv.run | bash


# ensure pyenv configured
# following lines should be added in .bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc

# install python 3.13 using pyenv
pyenv install 3.13

# create virtualenv
pyenv virtualenv 3.13 candid_3.13

# navigate to the project directory and set the virtual env
pyenv local candid_3.13


# install fastapi and other packaages
python -m pip install fastapi
# pip install fastapi uvicorn

# sometimes if you get error while installing fastapi, you can try the following
pip install "fastapi[all]"
pip install "fastapi[standard]"




# pip install pydantic-settings # settings in file
# pip install python-dotenv # operte with dotenv files

# run with uvicorn on https
# uvicorn app:app --host 0.0.0.0 --port 8000 --ssl-keyfile=key.pem --ssl-certfile=cert.pem




# kill the process running on port 8000
sudo lsof -t -i tcp:8000 | xargs kill -9

# connect to remote machine running the server
command ssh -L 8000:127.0.0.1:8000 candid

