import '../core/network/api_client.dart';
import 'secure_storage_service.dart';

class AuthRepository {
  final SecureStorageService _storage;
  final ApiClient _api;

  AuthRepository(this._storage, this._api);

  Future<bool> hasValidSession() async {
    final t = await _storage.readToken();
    return t != null && t.isNotEmpty;
  }

  /// Llama a POST /api/Login con { username, password }
  /// Espera un JSON que contenga el token (token|jwt|accessToken).
  Future<void> login(String user, String pass) async {
    final data = await _api.post('/api/Login', {
      'username': user,
      'password': pass,
    });

    // Ajusta si tu backend devuelve otra propiedad
    final token = (data['token'] ?? data['jwt'] ?? data['accessToken']) as String?;
    if (token == null || token.isEmpty) {
      throw Exception('No se recibió token del servidor.');
    }
    await _storage.saveToken(token);
  }

  Future<void> logout() => _storage.deleteToken();
}
