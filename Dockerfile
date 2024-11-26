# Gunakan base image Python
FROM python:3.10-slim

# Set direktori kerja
WORKDIR /app

# Install dependensi dasar
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    fonts-liberation \
    libasound2 \
    libnss3 \
    libx11-dev \
    libxcomposite-dev \
    libxrandr-dev \
    libgtk-3-0 \
    xdg-utils \
    gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Tambahkan kunci GPG dan repositori Google Chrome
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub -o /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Perbarui paket dan instal Google Chrome
RUN apt-get update && apt-get install -y google-chrome-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN wget -O chromedriver.zip https://chromedriver.storage.googleapis.com/$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip \
    && apt-get update && apt-get install -y unzip \
    && unzip chromedriver.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/chromedriver \
    && rm chromedriver.zip

# Salin aplikasi ke dalam container
COPY . /app

# Install dependensi Python
RUN pip install --no-cache-dir -r requirements.txt

# Jalankan aplikasi
CMD ["python", "app.py"]
