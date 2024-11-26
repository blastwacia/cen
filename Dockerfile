FROM python:3.10-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    ca-certificates \
    fontconfig \
    libx11-dev \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libgdk-pixbuf2.0-0 \
    libnss3 \
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    google-chrome-stable

# Install ChromeDriver
RUN wget -q -O - https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip | \
    unzip -d /usr/local/bin

# Set the environment variable for Chrome binary location
ENV CHROME_BIN="/usr/bin/google-chrome-stable"
