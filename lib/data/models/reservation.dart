enum ReservaEstado { pendiente, confirmada, cancelada }

class Reservation {
  final String bayId;        // ej. 'B1'
  final DateTime start;      // inicio
  final Duration duration;   // duración
  final ReservaEstado estado;

  Reservation({
    required this.bayId,
    required this.start,
    required this.duration,
    this.estado = ReservaEstado.confirmada,
  });

  DateTime get end => start.add(duration);
}
