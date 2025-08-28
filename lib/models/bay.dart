enum BayStatus { libre, ocupada, mantenimiento }

class Bay {
  final String id;
  final String nombre;
  final BayStatus estado;
  final int puestos;
  Bay({required this.id, required this.nombre, required this.estado, required this.puestos});
}