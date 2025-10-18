import '../../core/domain/entities/usuario.dart';
import '../../core/domain/repositories/usuarios_repository.dart';
import '../datasources/usuarios_remote_ds.dart';
import '../models/usuario_model.dart';

class UsuariosRepositoryImpl implements UsuariosRepository {
  final UsuariosRemoteDataSource remote;
  UsuariosRepositoryImpl(this.remote);

  @override
  Future<List<Usuario>> getAll() => remote.getAll();

  @override
  Future<Usuario> getById(int id) => remote.getById(id);

  @override
  Future<Usuario> getByUsername(String username) => remote.getByUsername(username);

  @override
  Future<Usuario> create(Usuario u) =>
      remote.create(_m(u));

  @override
  Future<Usuario> update(Usuario u) =>
      remote.update(_m(u));

  @override
  Future<void> delete(int id) => remote.delete(id);

  UsuarioModel _m(Usuario u) => UsuarioModel(
    id: u.id,
    username: u.username,
    email: u.email,
    nombre: u.nombre,
    apellido: u.apellido,
    estado: u.estado,
    roles: u.roles,
    password: u.password,
  );
}
