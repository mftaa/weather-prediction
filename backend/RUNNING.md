# Menjalankan Backend Weather Prediction

Dokumen singkat ini menjelaskan langkah-langkah menjalankan backend proyek `weather-prediction` di macOS (zsh). Isi berbahasa Indonesia dan berisi perintah yang bisa langsung dicopy-paste.

Server dev berjalan pada port 8000. Jika mesin kamu IP internal adalah 10.252.206.210, akses dari jaringan lokal menggunakan http://10.252.206.210:8000

Ringkasan langkah utama
- Aktifkan virtual environment
- Install dependency Python (opsi cepat: `mysql-connector-python`) atau (opsi lengkap: `mysqlclient`)
- Pastikan MySQL server berjalan dan import file `weather_app_bd.sql`
- Pastikan file model `rf_model_pkl` ada (jalankan `create_model.py` jika perlu)
- Jalankan server dengan `uvicorn`

Persiapan (sekali saja)

1) Masuk ke direktori project

```zsh
cd /Users/hanifabdusy/Downloads/weather-prediction/backend
```

2) Buat dan aktifkan virtual environment

```zsh
python3 -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
```

Opsi A — (Direkomendasikan untuk cepat) Pakai mysql-connector (tidak perlu build native)

```zsh
pip install fastapi uvicorn bcrypt numpy scikit-learn pandas requests python-dotenv mysql-connector-python
```

Setelah ini, buka `main.py` dan ubah import + konfigurasi DB (jika belum):

```py
import mysql.connector

db_config = {
    'host': '127.0.0.1',   # gunakan 127.0.0.1 untuk menghindari socket issues
    'user': 'root',
    'password': '',        # isi kalau punya password
    'database': 'weather_app_bd',
    'port': 3306
}

conn = mysql.connector.connect(**db_config)
```

Opsi B — (Lengkap) Pakai mysqlclient (butuh dependensi sistem)

Jika kamu perlu menggunakan `MySQLdb` (mysqlclient), install dependensi sistem dulu:

```zsh
# install Homebrew jika belum ada: https://brew.sh/
brew install pkg-config mysql-client
# tambahkan flags (sesuaikan prefix bila diperlukan)
echo 'export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"' >> ~/.zshrc
echo 'export LDFLAGS="-L/opt/homebrew/opt/mysql-client/lib"' >> ~/.zshrc
echo 'export CPPFLAGS="-I/opt/homebrew/opt/mysql-client/include"' >> ~/.zshrc
echo 'export PKG_CONFIG_PATH="/opt/homebrew/opt/mysql-client/lib/pkgconfig"' >> ~/.zshrc
source ~/.zshrc

# kemudian di venv:
source venv/bin/activate
pip install fastapi uvicorn mysqlclient bcrypt numpy scikit-learn pandas requests python-dotenv
```

Menyiapkan database

1) Pastikan MySQL server berjalan:

```zsh
# jika MySQL diinstall via Homebrew
brew services start mysql
# atau
mysql.server start
```

2) Import file SQL (ada di root folder `backend`)

```zsh
# jika root tanpa password
mysql -u root < weather_app_bd.sql
# bila ada password:
# mysql -u root -p < weather_app_bd.sql
```

Jika muncul error "Unknown database 'weather_app_bd'" berarti database belum dibuat — import SQL akan membuat struktur yang diperlukan.

Model ML

File model yang digunakan oleh API bernama `rf_model_pkl`. Jika tidak ada, buat model dummy (satu kali) dengan:

```zsh
python create_model.py
# ini akan membuat file 'rf_model_pkl' di folder saat berhasil
```

Menjalankan server

```zsh
# aktifkan venv jika perlu
source venv/bin/activate
# jalankan uvicorn (development)
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Akses API

- Dokumentasi interaktif (Swagger UI): http://127.0.0.1:8000/docs
- ReDoc: http://127.0.0.1:8000/redoc
- Jika mengakses dari mesin lain di jaringan lokal, gunakan IP-mu: http://10.252.206.210:8000

Smoke test contoh (curl)

```zsh
# cek docs
curl -i http://127.0.0.1:8000/docs

# panggil endpoint prediksi (contoh)
curl -s "http://127.0.0.1:8000/weather-data/get-predicted-data?day=1&month=1&year=2020" | jq .
```

Troubleshooting umum

- ModuleNotFoundError: No module named 'fastapi' → aktifkan `venv` dan jalankan `pip install fastapi uvicorn`.
- Error saat install `mysqlclient` (pkg-config not found / Can not find valid pkg-config name): install `pkg-config` dan `mysql-client` via Homebrew (lihat Opsi B).
- Can't connect through socket '/tmp/mysql.sock' → ubah host jadi `127.0.0.1` di `db_config` atau tentukan `unix_socket` ke path yang benar (contoh Homebrew di Apple Silicon: `/opt/homebrew/var/run/mysql/mysql.sock`).
- Unknown database 'weather_app_bd' → import `weather_app_bd.sql` atau buat database secara manual.
- Email OTP: kredensial email saat ini di-hardcode; jangan gunakan kredensial nyata di repo publik. Untuk pengembangan lokal, kamu bisa menonaktifkan `send_email` atau gunakan SMTP test account.

Option: make connection lazy (recommended for dev)

Jika ingin server tetap start walau DB belum siap, ubah agar koneksi dibuat saat pertama kali dipakai. Contoh pola:

```py
conn = None

def get_conn():
    global conn
    if conn is None:
        conn = mysql.connector.connect(**db_config)
    return conn

# lalu gunakan get_conn().cursor() di tempat yang sekarang pakai conn.cursor()
```

Catatan keamanan & produksi

- Jangan commit kredensial (email/password DB) ke repo. Gunakan `.env` dan `python-dotenv` atau secrets manager.
- Untuk deployment produksi, pakai Gunicorn/uvicorn workers, HTTPS, dan atur koneksi DB pooling.

Jika butuh, saya bisa membuat patch otomatis untuk:
- mengganti `MySQLdb` → `mysql.connector` dan update `db_config`, atau
- menambahkan root route kecil agar `GET /` tidak 404, atau
- membuat `requirements.txt` dari dependensi yang digunakan.

---

Dokument dibuat: 2025-12-04
