import '../services/api_service.dart';

String myUsername = "";

// Gunakan ApiService untuk mendapatkan domain dengan fallback otomatis
// Primary: https://api.wrseno.my.id (VPS)
// Secondary: https://api.azanifattur.biz.id (Personal Computer)
String get myDomain => ApiService.currentDomain;
