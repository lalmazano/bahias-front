import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_repository.dart';
import '../../services/secure_storage_service.dart';

/// Estado simple de auth
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({required this.isAuthenticated, this.isLoading = false, this.error});

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, String? error}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Proveedores base
final secureStorageProvider = Provider((ref) => SecureStorageService());
final authRepositoryProvider = Provider((ref) => AuthRepository(ref.read(secureStorageProvider)));

/// Controlador de auth (reactivo)
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthController(repo)..checkSession();
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthController(this._repo) : super(const AuthState(isAuthenticated: false, isLoading: true));

  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true, error: null);
    final valid = await _repo.hasValidSession();
    state = state.copyWith(isAuthenticated: valid, isLoading: false);
  }

  Future<void> login(String user, String pass) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.login(user, pass);
      state = state.copyWith(isAuthenticated: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = state.copyWith(isAuthenticated: false);
  }
}
