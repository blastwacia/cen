# Gunakan image dasar yang sesuai
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Tambahkan kunci GPG dan repositori Google Chrome
RUN curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Update dan install Google Chrome
RUN apt-get update && apt-get install -y google-chrome-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN wget -O /usr/local/bin/chromedriver https://chromedriver.storage.googleapis.com/$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip \
    && apt-get update && apt-get install -y unzip \
    && unzip /usr/local/bin/chromedriver -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/chromedriver \
    && rm chromedriver_linux64.zip

# Salin aplikasi ke dalam container
COPY . /app

# Install dependensi Python
RUN pip install --no-cache-dir -r requirements.txt

# Jalankan aplikasi
CMD ["python", "app.py"]
