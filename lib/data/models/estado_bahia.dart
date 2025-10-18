class EstadoBahia {
  final int idEstado;
  final String nombre;
  final String descripcion;

  EstadoBahia({
    required this.idEstado,
    required this.nombre,
    required this.descripcion,
  });

  factory EstadoBahia.fromJson(Map<String, dynamic> json) {
    return EstadoBahia(
      idEstado: json['idEstado'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEstado': idEstado,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
