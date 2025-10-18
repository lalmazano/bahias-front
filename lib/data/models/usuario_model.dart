// data/models/usuario_model.dart
import '../../core/domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  UsuarioModel({
    required super.id,
    required super.username,
    required super.email,
    required super.nombre,
    required super.apellido,
    required super.estado,
    required super.roles,
    super.password
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> j) => UsuarioModel(
    id: j['id'],
    username: j['username'] ?? '',
    email: j['email'] ?? '',
    nombre: j['nombre'] ?? '',
    apellido: j['apellido'] ?? '',
    estado: j['estado'] ?? '',
    roles: (j['roles'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    password: j['password'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'nombre': nombre,
    'apellido': apellido,
    'estado': estado,
    'roles': roles,
    'password': password
  };
}
