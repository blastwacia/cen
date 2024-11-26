FROM python:3.10-slim

# Install dependencies and Google Chrome
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    libx11-dev \
    libxcomposite-dev \
    libxrandr-dev \
    libgtk-3-0 \
    libnss3 \
    libasound2 \
    fonts-liberation \
    xdg-utils \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O google-chrome-stable_current_amd64.deb \
    && dpkg -i google-chrome-stable_current_amd64.deb \
    && apt-get -y --fix-broken install

# Install ChromeDriver
RUN wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/local/bin

# Install required Python packages
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

# Set work directory
WORKDIR /app
