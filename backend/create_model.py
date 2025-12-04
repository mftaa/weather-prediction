import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
import pickle

# 1. Buat Dataset Dummy (Palsu)
# Ini hanya agar kode berjalan. Untuk hasil akurat, kamu butuh data asli dari Visual Crossing.
# Format input (X): [Day, Month, Year]
# Format output (y): [tempmax, tempmin, temp, humidity, windspeed, pressure, conditions]

print("Sedang membuat data dummy...")
data = {
    'day': np.random.randint(1, 29, 1000),
    'month': np.random.randint(1, 13, 1000),
    'year': np.random.randint(2000, 2025, 1000),
    'tempmax': np.random.uniform(25, 35, 1000),
    'tempmin': np.random.uniform(20, 25, 1000),
    'temp': np.random.uniform(22, 30, 1000),
    'humidity': np.random.uniform(40, 90, 1000),
    'windspeed': np.random.uniform(0, 20, 1000),
    'pressure': np.random.uniform(1000, 1020, 1000),
    'conditions': np.random.randint(0, 6, 1000) # 0-5 sesuai mapping di main.py
}

df = pd.DataFrame(data)

# Pisahkan fitur (X) dan target (y)
X = df[['day', 'month', 'year']]
y = df[['tempmax', 'tempmin', 'temp', 'humidity', 'windspeed', 'pressure', 'conditions']]

# 2. Latih Model Random Forest
print("Sedang melatih model Random Forest...")
rf_model = RandomForestRegressor(n_estimators=100, random_state=42)
rf_model.fit(X, y)

# 3. Simpan Model menjadi file .pkl
filename = 'rf_model_pkl'
with open(filename, 'wb') as file:
    pickle.dump(rf_model, file)

print(f"Sukses! File '{filename}' berhasil dibuat.")