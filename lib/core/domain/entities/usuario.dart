class Usuario {
  final int id;
  final String username, email, nombre, apellido, estado;
  final List<String> roles;
  Usuario({
    required this.id,
    required this.username,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.estado,
    required this.roles,
  });
}