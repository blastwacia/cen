# Gunakan image base Python
FROM python:3.10-slim

# Instal dependensi untuk Chrome dan ChromeDriver
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libxss1 \
    libx11-xcb1 \
    libgbm1 \
    && rm -rf /var/lib/apt/lists/*

# Download dan install Google Chrome
RUN curl -sS https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome.deb
RUN dpkg -i google-chrome.deb
RUN apt-get -y --fix-broken install

# Install ChromeDriver
RUN wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip
RUN mv chromedriver /usr/local/bin/
RUN chmod +x /usr/local/bin/chromedriver

# Instal dependensi Python
WORKDIR /app
COPY requirements.txt /app/
RUN pip install -r requirements.txt

# Copy aplikasi Anda
COPY . /app/

# Tentukan perintah untuk menjalankan aplikasi
CMD ["python", "app.py"]
