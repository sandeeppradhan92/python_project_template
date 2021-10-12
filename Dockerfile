FROM ubuntu:20.04

LABEL maintainer="TheMathComapny <>"

# Arguments / Variables
# ================================================================================================
ARG USER=appuser

ENV LOG_DIR=/logs

# Create and configure user
# Ensure sudo group users are not asked for a password when using
# sudo command by ammending sudoers file
# ================================================================================================
RUN useradd -ms /bin/bash ${USER} && \
    usermod -aG sudo ${USER} && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get update -y && apt-get install \
    -y --no-install-recommends \
    python3.8 \
    python3-pip \
    python3-dev \
    build-essential \
    gcc \
    unixodbc \
    unixodbc-dev \
    gnupg2 \
    curl \
    gunicorn

# Add SQL Server ODBC Driver 17 for Ubuntu 20.04
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y --allow-unauthenticated msodbcsql17

RUN python3 -m pip install --upgrade pip

RUN mkdir -p /logs && chmod 777 /logs

USER ${USER}

RUN python3 -m pip install --no-cache-dir setuptools wheel

COPY . /src/

RUN python3 -m pip install --no-cache-dir -r /src/requirements.txt

WORKDIR /src/

EXPOSE 8000

CMD gunicorn --bind 0.0.0.0:8000 --workers=2 -t 600 'app:create_app()' --keep-alive 5 --log-level info