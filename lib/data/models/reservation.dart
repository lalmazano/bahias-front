// lib/data/models/reservation.dart
class Reservation {
  final int idReserva;
  final int idUsuario;
  final DateTime inicioTs;
  final DateTime finTs;
  final int idVehiculo;
  final int estado;
  final String? observacion;
  final DateTime creadoEn;
  final List<BayReserva>? bahia; // relación con bahías

  Reservation({
    required this.idReserva,
    required this.idUsuario,
    required this.inicioTs,
    required this.finTs,
    required this.idVehiculo,
    required this.estado,
    this.observacion,
    required this.creadoEn,
    this.bahia,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      idReserva: json['idReserva'] ?? 0,
      idUsuario: json['idUsuario'] ?? 0,
      inicioTs: DateTime.parse(json['inicioTs']),
      finTs: DateTime.parse(json['finTs']),
      idVehiculo: json['idVehiculo'] ?? 0,
      estado: json['estado'] ?? 0,
      observacion: json['observacion'],
      creadoEn: DateTime.parse(json['creadoEn']),
      bahia: json['bahia'] != null
          ? (json['bahia'] as List)
              .map((b) => BayReserva.fromJson(b))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idReserva': idReserva,
      'idUsuario': idUsuario,
      'inicioTs': inicioTs.toIso8601String(),
      'finTs': finTs.toIso8601String(),
      'idVehiculo': idVehiculo,
      'estado': estado,
      'observacion': observacion,
      'creadoEn': creadoEn.toIso8601String(),
      'bahia': bahia?.map((b) => b.toJson()).toList(),
    };
  }
}

class BayReserva {
  final int idBahia;
  final int idUbicacion;
  final int idEstado;
  final int idReserva;
  final DateTime fechaCreacion;

  BayReserva({
    required this.idBahia,
    required this.idUbicacion,
    required this.idEstado,
    required this.idReserva,
    required this.fechaCreacion,
  });

  factory BayReserva.fromJson(Map<String, dynamic> json) {
    return BayReserva(
      idBahia: json['idBahia'] ?? 0,
      idUbicacion: json['idUbicacion'] ?? 0,
      idEstado: json['idEstado'] ?? 0,
      idReserva: json['idReserva'] ?? 0,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBahia': idBahia,
      'idUbicacion': idUbicacion,
      'idEstado': idEstado,
      'idReserva': idReserva,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }
}
