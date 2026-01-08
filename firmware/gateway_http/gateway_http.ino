/*
 * Weather Monitoring System - Gateway (HTTP Legacy Version)
 * Hardware: ESP32-S3 + LoRa SX1278 RA-02 433MHz
 * 
 * FIXED: WiFi Auto-Reconnect + RGB LED Status
 * 
 */

#include <SPI.h>
#include <LoRa.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <Adafruit_NeoPixel.h>

// ===== CONSTANTS =====
const int MAX_PACKET_SIZE = 128;
const unsigned long SEND_RETRY_INTERVAL_MS = 10000;
const unsigned long HTTP_TIMEOUT_MS = 8000;
const int WIFI_RECONNECT_ATTEMPTS = 30;
const unsigned long WIFI_RECONNECT_DELAY_MS = 500;

// ===== SENSOR VALIDATION RANGES =====
const float TEMP_MIN = -50.0;
const float TEMP_MAX = 70.0;
const float HUM_MIN = 0.0;
const float HUM_MAX = 100.0;
const float PRESS_MIN = 800.0;
const float PRESS_MAX = 1200.0;
const float WIND_MIN = 0.0;
const float WIND_MAX = 200.0;
const int LDR_MIN_ANALOG = 0;
const int LDR_MAX_ANALOG = 1024;

// ===== DATA BUFFERING =====
struct WeatherData {
  float temp;
  float humidity;
  float pressure;
  float windSpeed;
  int isRaining;
  int lightIntensity;
  bool valid;
};

WeatherData lastData = {0, 0, 0, 0, 0, 0, false};
bool newDataAvailable = false;
bool isProcessingData = false;
unsigned long lastSendAttemptMs = 0;

// ===== PIN CONFIGURATION ESP32-S3 =====
#define LORA_SCK   12
#define LORA_MISO  13
#define LORA_MOSI  11
#define LORA_SS    10
#define LORA_RST   8
#define LORA_DIO0  9

// ===== RGB LED CONFIGURATION (WS2812B) =====
#define RGB_LED_PIN 48
#define RGB_LED_COUNT 1
#define RGB_BRIGHTNESS 50

Adafruit_NeoPixel rgbLed(RGB_LED_COUNT, RGB_LED_PIN, NEO_GRB + NEO_KHZ800);

// Definisi warna RGB
#define RGB_OFF      rgbLed.Color(0, 0, 0)
#define RGB_RED      rgbLed.Color(255, 0, 0)
#define RGB_GREEN    rgbLed.Color(0, 255, 0)
#define RGB_BLUE     rgbLed.Color(0, 0, 255)
#define RGB_YELLOW   rgbLed.Color(255, 255, 0)
#define RGB_CYAN     rgbLed.Color(0, 255, 255)
#define RGB_MAGENTA  rgbLed.Color(255, 0, 255)
#define RGB_WHITE    rgbLed.Color(255, 255, 255)
#define RGB_ORANGE   rgbLed.Color(255, 165, 0)
#define RGB_PURPLE   rgbLed.Color(128, 0, 255)

// ===== LED INDICATOR =====
#define LORA_LED 4

// ===== WIFI CONFIGURATION =====
const char* WIFI_SSID = "KelompokCuaca";
const char* WIFI_PASSWORD = "esTeHangetSegar";

// ===== BACKEND CONFIGURATION =====
const char* BACKEND_URL_1 = "https://api.azanifattur.biz.id";
const char* BACKEND_URL_2 = "https://api.wrseno.my.id";
const char* BACKEND_URLS[] = {BACKEND_URL_1, BACKEND_URL_2};
const int NUM_ENDPOINTS = 2;

// ===== WIFI STATE =====
unsigned long lastWiFiCheckMs = 0;
const unsigned long WIFI_CHECK_INTERVAL_MS = 5000;
bool isReconnecting = false;
unsigned long reconnectStartMs = 0;
int reconnectAttempts = 0;

// ===== STATISTICS =====
unsigned long packetCount = 0;
unsigned long successCount = 0;
unsigned long failCount = 0;

// ===== RGB LED FUNCTIONS =====
void setRGB(uint32_t color) {
  rgbLed.setPixelColor(0, color);
  rgbLed.show();
}

void blinkRGB(uint32_t color, int times = 1, int delayMs = 200) {
  for (int i = 0; i < times; i++) {
    setRGB(color);
    delay(delayMs);
    setRGB(RGB_OFF);
    if (i < times - 1) delay(delayMs);
  }
}

// ===== FUNCTION DECLARATIONS =====
void setupWiFi();
void checkWiFiConnection();
void attemptWiFiReconnect();
bool handleLoRaPacket(int packetSize);
bool parseWeatherData(const String& dataPayload, WeatherData& data);
bool validateSensorData(const WeatherData& data);
int sendToAllEndpoints(const WeatherData& data);
bool sendToEndpoint(const char* backendUrl, const WeatherData& data);
String buildURLQuery(const char* baseUrl, const WeatherData& data);
void printUptime();
void printStats();

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("\n\n===== Weather Gateway (WiFi Auto-Reconnect Fixed) =====");
  Serial.println("Version: ESP32-S3 with WS2812B RGB LED + Persistent WiFi");
  
  // Setup RGB LED (WS2812B)
  rgbLed.begin();
  rgbLed.setBrightness(RGB_BRIGHTNESS);
  rgbLed.show();
  
  // Test RGB LED
  Serial.println("Testing RGB LED...");
  setRGB(RGB_RED);
  delay(300);
  setRGB(RGB_GREEN);
  delay(300);
  setRGB(RGB_BLUE);
  delay(300);
  setRGB(RGB_OFF);
  
  // Setup LED eksternal
  pinMode(LORA_LED, OUTPUT);
  digitalWrite(LORA_LED, LOW);
  
  // Setup LoRa
  setRGB(RGB_YELLOW);
  SPI.begin(LORA_SCK, LORA_MISO, LORA_MOSI, LORA_SS);
  LoRa.setPins(LORA_SS, LORA_RST, LORA_DIO0);
  LoRa.setSPIFrequency(1E6);
  
  if (!LoRa.begin(433E6)) {
    Serial.println("✗ LoRa init failed!");
    blinkRGB(RGB_RED, 10, 200);
  } else {
    LoRa.setSpreadingFactor(12);
    LoRa.setSignalBandwidth(125E3);
    LoRa.setCodingRate4(8);
    LoRa.setSyncWord(0x12);
    LoRa.setTxPower(20);
    Serial.println("✓ LoRa initialized!");
    blinkRGB(RGB_GREEN, 2, 200);
  }
  
  // Setup WiFi
  setupWiFi();
  
  Serial.println("\n✓ Gateway ready! Waiting for LoRa packets...");
  Serial.println("Mode: Auto WiFi reconnect + Immediate send\n");
  
  if (WiFi.status() == WL_CONNECTED) {
    setRGB(RGB_BLUE); // Blue = Ready with WiFi
  } else {
    setRGB(RGB_PURPLE); // Purple = Ready but no WiFi
  }
}

void loop() {
  // PRIORITAS TINGGI: Kelola WiFi reconnection
  checkWiFiConnection();
  
  // Check for LoRa packets
  int packetSize = LoRa.parsePacket();
  if (packetSize > 0) {
    handleLoRaPacket(packetSize);
  }

  // Retry kirim data buffer setiap 10 detik
  unsigned long nowMs = millis();
  if (newDataAvailable && !isProcessingData && 
      (nowMs - lastSendAttemptMs >= SEND_RETRY_INTERVAL_MS)) {
    
    // Hanya coba kirim jika WiFi connected
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("\n[RETRY SKIP] WiFi not connected, keeping data buffered");
      lastSendAttemptMs = nowMs; // Update timer untuk coba lagi nanti
      return;
    }
    
    isProcessingData = true;
    
    Serial.println("\n[RETRY] Attempting to send buffered data...");
    printUptime();
    
    setRGB(RGB_ORANGE);
    int sentCount = sendToAllEndpoints(lastData);
    lastSendAttemptMs = nowMs;
    
    if (sentCount > 0) {
      newDataAvailable = false;
      successCount++;
      Serial.println("[RETRY] ✓ Data sent successfully, buffer cleared");
      blinkRGB(RGB_GREEN, 2, 200);
      setRGB(RGB_BLUE);
      printStats();
    } else {
      failCount++;
      Serial.println("[RETRY] ✗ All endpoints failed, will retry in 10 seconds");
      blinkRGB(RGB_RED, 3, 200);
      setRGB(WiFi.status() == WL_CONNECTED ? RGB_BLUE : RGB_PURPLE);
    }
    
    isProcessingData = false;
  }
  
  delay(10);
}

void setupWiFi() {
  Serial.println();
  Serial.print("Connecting to WiFi: ");
  Serial.println(WIFI_SSID);
  
  WiFi.mode(WIFI_STA);
  WiFi.setAutoReconnect(true); // Enable auto-reconnect
  WiFi.persistent(true);        // Save config to flash
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < WIFI_RECONNECT_ATTEMPTS) {
    delay(WIFI_RECONNECT_DELAY_MS);
    Serial.print(".");
    setRGB((attempts % 2 == 0) ? RGB_CYAN : RGB_OFF);
    attempts++;
  }
  
  Serial.println();
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("✓ WiFi connected!");
    Serial.print("  IP address: ");
    Serial.println(WiFi.localIP());
    Serial.print("  Signal: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
    blinkRGB(RGB_GREEN, 3, 200);
  } else {
    Serial.println("✗ WiFi connection failed!");
    Serial.println("  Gateway will continue and retry in background");
    blinkRGB(RGB_RED, 5, 200);
  }
  
  isReconnecting = false;
}

void checkWiFiConnection() {
  unsigned long nowMs = millis();
  
  // Cek setiap WIFI_CHECK_INTERVAL_MS
  if (nowMs - lastWiFiCheckMs < WIFI_CHECK_INTERVAL_MS) {
    return;
  }
  
  lastWiFiCheckMs = nowMs;
  
  // Jika disconnected dan belum dalam proses reconnect
  if (WiFi.status() != WL_CONNECTED && !isReconnecting) {
    Serial.println("\n⚠ WiFi disconnected, starting reconnection process...");
    isReconnecting = true;
    reconnectStartMs = nowMs;
    reconnectAttempts = 0;
    setRGB(RGB_MAGENTA); // Magenta = reconnecting
  }
  
  // Jika sedang dalam proses reconnect
  if (isReconnecting) {
    attemptWiFiReconnect();
  }
}

void attemptWiFiReconnect() {
  // Cek apakah sudah berhasil connect
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("✓ WiFi reconnected!");
    Serial.print("  IP address: ");
    Serial.println(WiFi.localIP());
    Serial.print("  Signal: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
    blinkRGB(RGB_GREEN, 2, 200);
    setRGB(RGB_BLUE);
    isReconnecting = false;
    reconnectAttempts = 0;
    return;
  }
  
  unsigned long nowMs = millis();
  
  // Coba reconnect setiap WIFI_RECONNECT_DELAY_MS
  if (nowMs - reconnectStartMs >= (reconnectAttempts * WIFI_RECONNECT_DELAY_MS)) {
    reconnectAttempts++;
    
    Serial.print("  Reconnect attempt ");
    Serial.print(reconnectAttempts);
    Serial.print("/");
    Serial.print(WIFI_RECONNECT_ATTEMPTS);
    Serial.print("...");
    
    // Blink magenta saat mencoba
    setRGB((reconnectAttempts % 2 == 0) ? RGB_MAGENTA : RGB_OFF);
    
    if (reconnectAttempts == 1) {
      // First attempt: just reconnect
      WiFi.reconnect();
    } else if (reconnectAttempts % 5 == 0) {
      // Every 5 attempts: full restart
      Serial.println(" [Full restart]");
      WiFi.disconnect();
      delay(500);
      WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    }
    
    // Timeout setelah WIFI_RECONNECT_ATTEMPTS
    if (reconnectAttempts >= WIFI_RECONNECT_ATTEMPTS) {
      Serial.println("\n✗ WiFi reconnection timeout!");
      Serial.println("  Will retry in next check cycle");
      isReconnecting = false;
      reconnectAttempts = 0;
      setRGB(RGB_PURPLE); // Purple = no WiFi
    }
  }
}

void printUptime() {
  unsigned long uptimeSec = millis() / 1000;
  unsigned long hours = uptimeSec / 3600;
  unsigned long minutes = (uptimeSec % 3600) / 60;
  unsigned long seconds = uptimeSec % 60;
  
  Serial.print("Uptime: ");
  if (hours < 10) Serial.print("0");
  Serial.print(hours);
  Serial.print(":");
  if (minutes < 10) Serial.print("0");
  Serial.print(minutes);
  Serial.print(":");
  if (seconds < 10) Serial.print("0");
  Serial.print(seconds);
  
  // Tambahkan status WiFi
  Serial.print(" | WiFi: ");
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("Connected (");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm)");
  } else {
    Serial.println("Disconnected");
  }
}

void printStats() {
  Serial.println("\n--- Statistics ---");
  Serial.print("Packets Received: ");
  Serial.println(packetCount);
  Serial.print("Send Success: ");
  Serial.println(successCount);
  Serial.print("Send Failed: ");
  Serial.println(failCount);
  
  if (packetCount > 0) {
    float successRate = (float)successCount / packetCount * 100.0;
    Serial.print("Success Rate: ");
    Serial.print(successRate, 1);
    Serial.println("%");
  }
  Serial.println("------------------\n");
}

bool handleLoRaPacket(int packetSize) {
  if (isProcessingData) {
    Serial.println("⚠ Skipping packet - currently processing previous data");
    return false;
  }
  
  setRGB(RGB_CYAN);
  
  String received = "";
  received.reserve(MAX_PACKET_SIZE);
  
  while (LoRa.available() && received.length() < MAX_PACKET_SIZE) {
    received += (char)LoRa.read();
  }
  
  while (LoRa.available()) {
    LoRa.read();
  }
  
  int rssi = LoRa.packetRssi();
  float snr = LoRa.packetSnr();
  
  Serial.println("\n========================================");
  Serial.println("       LoRa Packet Received");
  Serial.println("========================================");
  printUptime();
  Serial.println("Raw Data: " + received);
  Serial.print("RSSI: "); Serial.print(rssi); Serial.print(" dBm | ");
  Serial.print("SNR: "); Serial.print(snr); Serial.println(" dB");
  
  packetCount++;
  
  if (received.length() == 0) {
    Serial.println("✗ Empty packet received");
    blinkRGB(RGB_RED, 1, 200);
    setRGB(WiFi.status() == WL_CONNECTED ? RGB_BLUE : RGB_PURPLE);
    return false;
  }
  
  if (received.length() >= MAX_PACKET_SIZE) {
    Serial.println("⚠ Packet truncated - exceeded MAX_PACKET_SIZE");
  }
  
  digitalWrite(LORA_LED, HIGH);
  
  // Validate CRC
  int lastPipeIndex = received.lastIndexOf('|');
  
  if (lastPipeIndex == -1 || lastPipeIndex == 0) {
    Serial.println("✗ Invalid format: No CRC separator found or empty data");
    digitalWrite(LORA_LED, LOW);
    blinkRGB(RGB_RED, 2, 200);
    setRGB(WiFi.status() == WL_CONNECTED ? RGB_BLUE : RGB_PURPLE);
    return false;
  }

  String dataPayload = received.substring(0, lastPipeIndex);
  String receivedCrcHex = received.substring(lastPipeIndex + 1);
  
  if (dataPayload.length() < 10) {
    Serial.println("✗ Payload too short");
    digitalWrite(LORA_LED, LOW);
    blinkRGB(RGB_RED, 2, 200);
    setRGB(WiFi.status() == WL_CONNECTED ? RGB_BLUE : RGB_PURPLE);
    return false;
  }
  
  uint8_t calculatedCrc = 0;
  for (unsigned int i = 0; i < dataPayload.length(); i++) {
    calculatedCrc ^= dataPayload[i];
  }
  
  char* endPtr;
  unsigned long crcValue = strtoul(receivedCrcHex.c_str(), &endPtr, 16);
  
  if (*endPtr != '\0' || crcValue > 0xFF) {
    Serial.println("✗ Invalid CRC format");
    digitalWrite(LORA_LED, LOW);
    blinkRGB(RGB_RED, 2, 200);
    setRGB(WiFi.status() == WL_CONNECTED ? RGB_BLUE : RGB_PURPLE);
    return false;
  }
  
  uint8_t receivedCrc = (uint8_t)crcValue;
  
  if (calculatedCrc != receivedCrc) {
    Serial.print("✗ CRC Mismatch! Calc: 0x"); Serial.print(calculatedCrc, HEX);
    Serial.print(", Recv: 0x"); Serial.println(receivedCrc, HEX);
    digitalWrite(LORA_LED, LOW);
    blinkRGB(RGB_RED, 3, 200);
    setRGB(WiFi.status() == WL_CONNECTED ? RGB_BLUE : RGB_PURPLE);
    return false;
  }
  
  Serial.println("✓ CRC Valid!");
  
  // Parse and validate data
  WeatherData newData;
  if (!parseWeatherData(dataPayload, newData)) {
    digitalWrite(LORA_LED, LOW);
    blinkRGB(RGB_RED, 2, 200);
    setRGB(WiFi.status() == WL_CONNECTED ? RGB_BLUE : RGB_PURPLE);
    return false;
  }
  
  if (!validateSensorData(newData)) {
    digitalWrite(LORA_LED, LOW);
    blinkRGB(RGB_RED, 2, 200);
    setRGB(WiFi.status() == WL_CONNECTED ? RGB_BLUE : RGB_PURPLE);
    return false;
  }
  
  // Buffer new data
  lastData = newData;
  newDataAvailable = true;
  lastSendAttemptMs = millis();
  
  // Cek WiFi sebelum kirim
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("\n⚠ WiFi not connected - Data buffered, will send when WiFi available");
    digitalWrite(LORA_LED, LOW);
    blinkRGB(RGB_ORANGE, 2, 200);
    setRGB(RGB_PURPLE);
    return true;
  }
  
  // Try immediate send
  isProcessingData = true;
  Serial.println("\n[IMMEDIATE SEND] Attempting to send data now...");
  setRGB(RGB_YELLOW);
  int sentCount = sendToAllEndpoints(lastData);
  
  if (sentCount > 0) {
    newDataAvailable = false;
    successCount++;
    Serial.println("[IMMEDIATE SEND] ✓ Data sent successfully");
    blinkRGB(RGB_GREEN, 2, 300);
    setRGB(RGB_BLUE);
    printStats();
  } else {
    failCount++;
    Serial.println("[IMMEDIATE SEND] ✗ All endpoints failed");
    Serial.println("⚠ Data buffered - will retry in 10 seconds");
    blinkRGB(RGB_RED, 3, 200);
    setRGB(RGB_BLUE);
  }
  
  isProcessingData = false;
  digitalWrite(LORA_LED, LOW);
  
  return true;
}

bool parseWeatherData(const String& dataPayload, WeatherData& data) {
  const int EXPECTED_FIELDS = 7;
  String fields[EXPECTED_FIELDS];
  int fieldCount = 0;
  int lastIndex = 0;
  
  for (unsigned int i = 0; i <= dataPayload.length(); i++) {
    if (dataPayload.charAt(i) == '|' || i == dataPayload.length()) {
      if (fieldCount >= EXPECTED_FIELDS) {
        Serial.println("✗ Too many fields in payload");
        return false;
      }
      
      fields[fieldCount] = dataPayload.substring(lastIndex, i);
      
      if (fields[fieldCount].length() == 0) {
        Serial.print("✗ Empty field at index ");
        Serial.println(fieldCount);
        return false;
      }
      
      lastIndex = i + 1;
      fieldCount++;
    }
  }
  
  if (fieldCount != EXPECTED_FIELDS) {
    Serial.print("✗ Invalid field count: ");
    Serial.print(fieldCount);
    Serial.print(" (expected ");
    Serial.print(EXPECTED_FIELDS);
    Serial.println(")");
    return false;
  }
  
  String deviceId = fields[0];
  data.temp = fields[1].toFloat();
  data.humidity = fields[2].toFloat();
  data.pressure = fields[3].toFloat();
  data.windSpeed = fields[4].toFloat();
  data.isRaining = fields[5].toInt();
  data.lightIntensity = fields[6].toInt();
  data.valid = true;
  
  Serial.println("\n╔════════════════════════════════════╗");
  Serial.println("║    Decoded Weather Data           ║");
  Serial.println("╠════════════════════════════════════╣");
  Serial.print("║ Device ID    : "); Serial.println(deviceId);
  Serial.print("║ Temperature  : "); Serial.print(data.temp, 2); Serial.println(" °C");
  Serial.print("║ Humidity     : "); Serial.print(data.humidity, 2); Serial.println(" %");
  Serial.print("║ Pressure     : "); Serial.print(data.pressure, 2); Serial.println(" hPa");
  Serial.print("║ Wind Speed   : "); Serial.print(data.windSpeed, 2); Serial.println(" km/h");
  Serial.print("║ Rain Status  : "); Serial.println(data.isRaining == 1 ? "Wet (Raining)" : "Dry");
  Serial.print("║ Light Level  : "); Serial.println(data.lightIntensity);
  Serial.println("╚════════════════════════════════════╝");
  
  return true;
}

bool validateSensorData(const WeatherData& data) {
  bool valid = true;
  
  if (data.temp < TEMP_MIN || data.temp > TEMP_MAX) {
    Serial.print("✗ Temperature out of range: ");
    Serial.print(data.temp);
    Serial.print(" (valid: ");
    Serial.print(TEMP_MIN);
    Serial.print(" to ");
    Serial.print(TEMP_MAX);
    Serial.println(")");
    valid = false;
  }
  
  if (data.humidity < HUM_MIN || data.humidity > HUM_MAX) {
    Serial.print("✗ Humidity out of range: ");
    Serial.print(data.humidity);
    Serial.print(" (valid: ");
    Serial.print(HUM_MIN);
    Serial.print(" to ");
    Serial.print(HUM_MAX);
    Serial.println(")");
    valid = false;
  }
  
  if (data.pressure < PRESS_MIN || data.pressure > PRESS_MAX) {
    Serial.print("✗ Pressure out of range: ");
    Serial.print(data.pressure);
    Serial.print(" (valid: ");
    Serial.print(PRESS_MIN);
    Serial.print(" to ");
    Serial.print(PRESS_MAX);
    Serial.println(")");
    valid = false;
  }
  
  if (data.windSpeed < WIND_MIN || data.windSpeed > WIND_MAX) {
    Serial.print("✗ Wind speed out of range: ");
    Serial.print(data.windSpeed);
    Serial.print(" (valid: ");
    Serial.print(WIND_MIN);
    Serial.print(" to ");
    Serial.print(WIND_MAX);
    Serial.println(")");
    valid = false;
  }
  
  if (data.isRaining != 0 && data.isRaining != 1) {
    Serial.print("✗ Invalid rain status: ");
    Serial.print(data.isRaining);
    Serial.println(" (valid: 0 or 1)");
    valid = false;
  }
  
  if (data.lightIntensity < LDR_MIN_ANALOG || data.lightIntensity > LDR_MAX_ANALOG) {
    Serial.print("✗ Light intensity out of range: ");
    Serial.print(data.lightIntensity);
    Serial.print(" (valid: ");
    Serial.print(LDR_MIN_ANALOG);
    Serial.print(" to ");
    Serial.print(LDR_MAX_ANALOG);
    Serial.println(")");
    valid = false;
  }
  
  if (valid) {
    Serial.println("✓ All sensor values within valid ranges");
  }
  
  return valid;
}

String buildURLQuery(const char* baseUrl, const WeatherData& data) {
  char buffer[256];
  snprintf(buffer, sizeof(buffer),
           "%s/weather-data/create?temp=%.2f&humidity=%.2f&pressure=%.2f&windSpeed=%.2f&isRaining=%d&lightIntensity=%d",
           baseUrl, data.temp, data.humidity, data.pressure, 
           data.windSpeed, data.isRaining, data.lightIntensity);
  return String(buffer);
}

int sendToAllEndpoints(const WeatherData& data) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("⚠ WiFi Disconnected - Cannot send to any endpoint");
    return 0;
  }

  int successCount = 0;
  
  Serial.println("\n┌─────────────────────────────────────┐");
  Serial.println("│  Sending to Multiple Endpoints     │");
  Serial.println("└─────────────────────────────────────┘");
  
  for (int i = 0; i < NUM_ENDPOINTS; i++) {
    Serial.print("\n[Endpoint ");
    Serial.print(i + 1);
    Serial.print("/");
    Serial.print(NUM_ENDPOINTS);
    Serial.print("] ");
    Serial.println(BACKEND_URLS[i]);
    
    bool success = sendToEndpoint(BACKEND_URLS[i], data);
    
    if (success) {
      successCount++;
      Serial.println("  ✓ Success");
    } else {
      Serial.println("  ✗ Failed");
    }
  }
  
  Serial.println("\n┌─────────────────────────────────────┐");
  Serial.print("│  Result: ");
  Serial.print(successCount);
  Serial.print("/");
  Serial.print(NUM_ENDPOINTS);
  Serial.print(" endpoints succeeded");
  Serial.println("     │");
  Serial.println("└─────────────────────────────────────┘\n");
  
  return successCount;
}

bool sendToEndpoint(const char* backendUrl, const WeatherData& data) {
  HTTPClient http;
  
  String url = buildURLQuery(backendUrl, data);
  
  Serial.print("  URL: ");
  Serial.println(url);
  
  http.begin(url);
  http.setTimeout(HTTP_TIMEOUT_MS);
  
  unsigned long startMs = millis();
  int httpResponseCode = http.GET();
  unsigned long endMs = millis();
  
  Serial.print("  Response Time: ");
  Serial.print(endMs - startMs);
  Serial.println(" ms");
  
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.print("  HTTP Code: ");
    Serial.println(httpResponseCode);
    Serial.print("  Body: ");
    
    if (response.length() > 100) {
      Serial.println(response.substring(0, 100) + "...");
    } else {
      Serial.println(response);
    }
    
    http.end();
    return httpResponseCode >= 200 && httpResponseCode < 300;
  } else {
    Serial.print("  Error: ");
    Serial.println(http.errorToString(httpResponseCode));
    http.end();
    return false;
  }
}