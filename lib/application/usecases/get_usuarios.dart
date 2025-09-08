import '../../core/domain/entities/usuario.dart';
import '../../core/domain/repositories/usuarios_repository.dart';

class GetUsuarios {
  final UsuariosRepository repo;
  GetUsuarios(this.repo);
  Future<List<Usuario>> call() => repo.getAll();
}

class GetUsuarioById {
  final UsuariosRepository repo;
  GetUsuarioById(this.repo);
  Future<Usuario> call(int id) => repo.getById(id);
}

class GetUsuarioByUsername {
  final UsuariosRepository repo;
  GetUsuarioByUsername(this.repo);
  Future<Usuario> call(String username) => repo.getByUsername(username);
}

class CreateUsuario {
  final UsuariosRepository repo;
  CreateUsuario(this.repo);
  Future<Usuario> call(Usuario u) => repo.create(u);
}

class UpdateUsuario {
  final UsuariosRepository repo;
  UpdateUsuario(this.repo);
  Future<Usuario> call(Usuario u) => repo.update(u);
}

class DeleteUsuario {
  final UsuariosRepository repo;
  DeleteUsuario(this.repo);
  Future<void> call(int id) => repo.delete(id);
}

