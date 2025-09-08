import '../../core/network/api_client.dart';
import '../models/usuario_model.dart';

class UsuariosRemoteDataSource {
  final ApiClient api;
  UsuariosRemoteDataSource(this.api);

  Future<List<UsuarioModel>> getAll() async {
    final list = await api.get('/api/Usuarios') as List;
    return list.map((e) => UsuarioModel.fromJson(e)).toList();
  }

  Future<UsuarioModel> getById(int id) async {
    final data = await api.get('/api/Usuarios/$id');
    return UsuarioModel.fromJson(data);
  }

  Future<UsuarioModel> getByUsername(String username) async {
    final data = await api.get('/api/Usuarios/username/$username');
    return UsuarioModel.fromJson(data);
  }

  Future<UsuarioModel> create(UsuarioModel u) async {
    final data = await api.post('/api/Usuarios', u.toJson());
    return UsuarioModel.fromJson(data);
  }

  Future<UsuarioModel> update(UsuarioModel u) async {
    final data = await api.put('/api/Usuarios/${u.id}', u.toJson());
    // si el backend responde 204 sin cuerpo, data será null → reconsulta
    if (data == null) return getById(u.id);
    return UsuarioModel.fromJson(data);
  }

  Future<void> delete(int id) => api.delete('/api/Usuarios/$id');
}
