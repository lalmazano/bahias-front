class Bay {
  final int idBahia;
  final int idUbicacion;
  final int idEstado;
  final int? idReserva; // puede ser null
  final String fechaCreacion;

  Bay({
    required this.idBahia,
    required this.idUbicacion,
    required this.idEstado,
    this.idReserva,
    required this.fechaCreacion,
  });

  factory Bay.fromJson(Map<String, dynamic> json) {
    return Bay(
      idBahia: json['idBahia'],
      idUbicacion: json['idUbicacion'],
      idEstado: json['idEstado'],
      idReserva: json['idReserva'],
      fechaCreacion: json['fechaCreacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBahia': idBahia,
      'idUbicacion': idUbicacion,
      'idEstado': idEstado,
      'idReserva': idReserva,
      'fechaCreacion': fechaCreacion,
    };
  }
}
