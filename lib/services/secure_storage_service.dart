//import 'package:flutter/foundation.dart' show kIsWeb;
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_token';

  // 🔹 Temporal: no guardar nada, solo simular
  Future<void> saveToken(String token) async {
    // print('saveToken ignorado: $token');
    return;
  }

  Future<String?> getToken() async {
    // 🔹 Devuelve null siempre, como si no hubiera sesión guardada
    return null;
  }

  Future<void> deleteToken() async {
    // print('deleteToken ignorado');
    return;
  }
}