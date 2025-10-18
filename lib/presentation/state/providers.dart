// lib/presentation/state/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/env.dart';
import '../../core/network/api_client.dart';

import '../../data/datasources/usuarios_remote_ds.dart';
import '../../data/repositories/usuarios_repository_impl.dart';
import '../../core/domain/repositories/usuarios_repository.dart';
import '../../application/usecases/get_usuarios.dart';
import '../../services/auth_repository.dart';
import '../../services/secure_storage_service.dart';

/// Storage seguro
final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

/// Api client (inyecta baseUrl y proveedor de token)
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(
    baseUrl: Env.apiBaseUrl,
    tokenProvider: storage.readToken,
  );
});

// Data
final usuariosRemoteDsProvider =
    Provider((ref) => UsuariosRemoteDataSource(ref.watch(apiClientProvider)));

final usuariosRepositoryProvider = Provider<UsuariosRepository>(
  (ref) => UsuariosRepositoryImpl(ref.watch(usuariosRemoteDsProvider)),
);

// Use cases
final getUsuariosProvider        = Provider((ref) => GetUsuarios(ref.watch(usuariosRepositoryProvider)));
final getUsuarioByIdProvider     = Provider((ref) => GetUsuarioById(ref.watch(usuariosRepositoryProvider)));
final getUsuarioByUsernameProv   = Provider((ref) => GetUsuarioByUsername(ref.watch(usuariosRepositoryProvider)));
final createUsuarioProvider      = Provider((ref) => CreateUsuario(ref.watch(usuariosRepositoryProvider)));
final updateUsuarioProvider      = Provider((ref) => UpdateUsuario(ref.watch(usuariosRepositoryProvider)));
final deleteUsuarioProvider      = Provider((ref) => DeleteUsuario(ref.watch(usuariosRepositoryProvider)));

// Auth
/// AuthRepository (recibe storage + api)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(secureStorageProvider),
    ref.read(apiClientProvider),
  );
});
