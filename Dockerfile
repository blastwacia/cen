# Gunakan base image yang sudah terinstal Google Chrome
FROM selenium/standalone-chrome:latest

# Set direktori kerja
WORKDIR /app

# Salin aplikasi ke dalam container
COPY . /app

# Jalankan aplikasi atau skrip Anda
CMD ["echo", "Google Chrome sudah terinstal dan siap digunakan!"]
