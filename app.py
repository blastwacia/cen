from flask import Flask, request, render_template, jsonify
import pandas as pd
import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import urllib.parse
from time import sleep
from random import randint
import re
from werkzeug.utils import secure_filename
import traceback

app = Flask(__name__)

UPLOAD_FOLDER = "uploads"
ALLOWED_EXTENSIONS = {"csv"}
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

# Membuat folder upload jika belum ada
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Variabel global untuk melacak nomor yang berhasil dan gagal
sent_numbers = []
failed_numbers = []
last_sent_index = 0
driver = None

# Fungsi untuk memeriksa ekstensi file yang di-upload
def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS

# Fungsi untuk memvalidasi nomor telepon (format +62)
def is_valid_number(nomor):
    pattern = r'^\+62\d{8,15}$'
    return re.match(pattern, nomor) is not None

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/upload", methods=["POST"])
def upload_file():
    if "file" not in request.files:
        return jsonify({"status": "error", "message": "No file part in request."}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"status": "error", "message": "No file selected."}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config["UPLOAD_FOLDER"], filename)
        file.save(file_path)
        return jsonify({"status": "success", "message": f"File {filename} uploaded successfully.", "file_path": file_path})
    else:
        return jsonify({"status": "error", "message": "Invalid file type. Only CSV allowed."}), 400

@app.route("/login", methods=["GET"])
def login_whatsapp():
    global driver
    try:
        # Menginisialisasi WebDriver
        chrome_options = Options()
        chrome_options.add_argument("--headless")  # Jalankan Chrome tanpa antarmuka
        chrome_options.add_argument("--disable-gpu")  # Nonaktifkan GPU rendering
        chrome_options.add_argument("--no-sandbox")  # Nonaktifkan sandbox untuk kompatibilitas
        chrome_options.binary_location = "/usr/bin/google-chrome"  # Lokasi Chrome di server Render

        service = Service(executable_path="/usr/local/bin/chromedriver")  # Lokasi ChromeDriver di server Render
        driver = webdriver.Chrome(service=service, options=chrome_options)
        
        driver.get("https://web.whatsapp.com")
        WebDriverWait(driver, 120).until(EC.presence_of_element_located((By.XPATH, "//div[@id='app']")))

        # Menyimpan gambar QR code
        qr_code_element = WebDriverWait(driver, 120).until(
            EC.presence_of_element_located((By.XPATH, "//img[@alt='Scan me!']"))
        )
        qr_code_url = qr_code_element.get_attribute("src")

        # Menyimpan gambar QR ke dalam folder static
        qr_code_path = os.path.join('static', 'qr_code.png')
        driver.get(qr_code_url)
        driver.save_screenshot(qr_code_path)

        return jsonify({"status": "success", "message": "QR Code is shown, scan to login.", "qr_code": qr_code_path})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e), "traceback": traceback.format_exc()})

@app.route("/start", methods=["POST"])
def start_blasting():
    global sent_numbers, failed_numbers, last_sent_index, driver
    if not request.is_json:
        return jsonify({"status": "error", "message": "Request must be in JSON format."}), 400

    request_data = request.get_json()
    file_path = request_data.get("file_path")
    message_template = request_data.get("message", "").strip()

    if not file_path or not os.path.exists(file_path):
        return jsonify({"status": "error", "message": "Uploaded file not found."}), 400
    if not message_template:
        return jsonify({"status": "error", "message": "Message cannot be empty."}), 400

    try:
        # Membaca file CSV
        data = pd.read_csv(file_path, dtype={"NO HANDPHONE": str}).dropna(subset=["NO HANDPHONE"])
        data["NO HANDPHONE"] = data["NO HANDPHONE"].apply(lambda x: x.strip())

        # Memproses setiap baris dalam file CSV
        for index, row in data.iloc[last_sent_index:].iterrows():
            nomor = row["NO HANDPHONE"]
            if not is_valid_number(nomor):
                failed_numbers.append(nomor)
                continue

            pesan = message_template.replace("{USER_ID}", row.get("USER ID", "Unknown"))
            try:
                pesan_encoded = urllib.parse.quote(pesan)
                url = f"https://web.whatsapp.com/send?phone={nomor}&text={pesan_encoded}"
                driver.get(url)
                sleep(5)

                tombol_kirim = WebDriverWait(driver, 30).until(
                    EC.element_to_be_clickable((By.XPATH, "//span[@data-icon='send']"))
                )
                tombol_kirim.click()
                sent_numbers.append(nomor)
                last_sent_index += 1
            except Exception as e:
                failed_numbers.append(nomor)
                continue

        return jsonify({"status": "success", "message": "Messages sent successfully."})
    except Exception as e:
        return jsonify({"status": "error", "message": f"An error occurred: {str(e)}", "traceback": traceback.format_exc()})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)

print("Chrome binary location:", os.popen('which google-chrome').read())
print("ChromeDriver location:", os.popen('which chromedriver').read())

