// lib/presentation/state/usuarios_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/get_usuarios.dart';
import '../../core/domain/entities/usuario.dart';  // <- ojo: en "domain", no en "core"
import 'providers.dart';                      // <- mismo folder

class UsuariosState {
  final bool loading;
  final List<Usuario> data;
  final Object? error;
  const UsuariosState({this.loading=false, this.data=const [], this.error});
}

class UsuariosNotifier extends StateNotifier<UsuariosState> {
  final GetUsuarios _getAll;
  final CreateUsuario _create;
  final UpdateUsuario _update;
  final DeleteUsuario _delete;

  UsuariosNotifier(this._getAll, this._create, this._update, this._delete)
      : super(const UsuariosState()) {
    load();
  }

  Future<void> load() async {
    state = const UsuariosState(loading: true);
    try {
      final list = await _getAll();
      state = UsuariosState(data: list);
    } catch (e) {
      state = UsuariosState(error: e);
    }
  }

  Future<void> create(Usuario u) async {
    try {
      final nuevo = await _create(u);
      state = UsuariosState(data: [nuevo, ...state.data]);
    } catch (e) {
      state = UsuariosState(data: state.data, error: e);
    }
  }

  Future<void> update(Usuario u) async {
    try {
      final upd = await _update(u);
      final list = state.data.map((x) => x.id == upd.id ? upd : x).toList();
      state = UsuariosState(data: list);
    } catch (e) {
      state = UsuariosState(data: state.data, error: e);
    }
  }

  Future<void> remove(int id) async {
    try {
      await _delete(id);
      state = UsuariosState(data: state.data.where((x) => x.id != id).toList());
    } catch (e) {
      state = UsuariosState(data: state.data, error: e);
    }
  }
}

final usuariosNotifierProvider =
    StateNotifierProvider<UsuariosNotifier, UsuariosState>((ref) {
  return UsuariosNotifier(
    ref.read(getUsuariosProvider),
    ref.read(createUsuarioProvider),
    ref.read(updateUsuarioProvider),
    ref.read(deleteUsuarioProvider),
  );
});
