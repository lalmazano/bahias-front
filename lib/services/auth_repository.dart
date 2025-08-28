import 'secure_storage_service.dart';

class AuthRepository {
  final SecureStorageService _storage;
  AuthRepository(this._storage);

  // 🔒 Credenciales fijas de demo
  static const _demoUser = 'demo';
  static const _demoPass = 'Demo123*';

  Future<bool> hasValidSession() async {
    final t = await _storage.getToken();
    return t != null && t.isNotEmpty;
  }

  Future<void> login(String user, String pass) async {
    // ✅ Modo demo: valida contra usuario/contra fijos
    if (user == _demoUser && pass == _demoPass) {
      await _storage.saveToken('jwt_mock_${DateTime.now().millisecondsSinceEpoch}');
      return;
    }
    // ❌ Falla si no coincide
    throw Exception('Credenciales inválidas (usa: demo / Demo123*)');
  }

  Future<void> logout() => _storage.deleteToken();
}
