// lib/presentation/state/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/env.dart';
import '../../core/network/api_client.dart';

import '../../data/datasources/usuarios_remote_ds.dart';
import '../../data/repositories/usuarios_repository_impl.dart';
import '../../core/domain/repositories/usuarios_repository.dart';
import '../../application/usecases/get_usuarios.dart';

// Core
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: Env.apiBaseUrl,
    // tokenProvider: () => SecureStorageService().readToken(),
  );
});

// Data
final usuariosRemoteDsProvider =
    Provider((ref) => UsuariosRemoteDataSource(ref.watch(apiClientProvider)));

final usuariosRepositoryProvider = Provider<UsuariosRepository>(
  (ref) => UsuariosRepositoryImpl(ref.watch(usuariosRemoteDsProvider)),
);

// Use case
final getUsuariosProvider       = Provider((ref) => GetUsuarios(ref.watch(usuariosRepositoryProvider)));
final getUsuarioByIdProvider    = Provider((ref) => GetUsuarioById(ref.watch(usuariosRepositoryProvider)));
final getUsuarioByUsernameProv  = Provider((ref) => GetUsuarioByUsername(ref.watch(usuariosRepositoryProvider)));
final createUsuarioProvider     = Provider((ref) => CreateUsuario(ref.watch(usuariosRepositoryProvider)));
final updateUsuarioProvider     = Provider((ref) => UpdateUsuario(ref.watch(usuariosRepositoryProvider)));
final deleteUsuarioProvider     = Provider((ref) => DeleteUsuario(ref.watch(usuariosRepositoryProvider)));