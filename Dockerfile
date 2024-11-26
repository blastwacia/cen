# Gunakan base image yang ringan
FROM debian:bookworm-slim

# Set direktori kerja
WORKDIR /app

# Instal dependensi dasar
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

# Tambahkan keyring untuk repositori Google Chrome
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub -o /etc/apt/keyrings/google-chrome.gpg \
    && chmod 644 /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Perbarui repositori dan instal Google Chrome
RUN apt-get update && apt-get install -y google-chrome-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Salin aplikasi ke dalam container
COPY . /app

# Jalankan aplikasi
CMD ["echo", "Chrome berhasil diinstal!"]
