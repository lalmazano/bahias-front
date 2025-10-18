class Ubicacion {
  final int idUbicacion;
  final String nombre;
  final String detalle;

  Ubicacion({
    required this.idUbicacion,
    required this.nombre,
    required this.detalle,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      idUbicacion: json['idUbicacion'] ?? 0,
      nombre: json['nombre'] ?? '',
      detalle: json['detalle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUbicacion': idUbicacion,
      'nombre': nombre,
      'detalle': detalle,
    };
  }
}
