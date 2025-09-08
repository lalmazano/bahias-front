

import '../entities/usuario.dart';

abstract class UsuariosRepository {
  Future<List<Usuario>> getAll();
  Future<Usuario> getById(int id);
  Future<Usuario> getByUsername(String username);
  Future<Usuario> create(Usuario u);
  Future<Usuario> update(Usuario u); // usa u.id
  Future<void> delete(int id);
}