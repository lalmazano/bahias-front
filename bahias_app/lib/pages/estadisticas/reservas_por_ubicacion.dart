import 'package:flutter/material.dart';
import '../../services/services.dart';
import 'estadisticas.dart';

class ReservasPorUbicacion extends StatefulWidget {
  const ReservasPorUbicacion({super.key});

  @override
  State<ReservasPorUbicacion> createState() => _ReservasPorUbicacionState();
}

class _ReservasPorUbicacionState extends State<ReservasPorUbicacion> {
  final service = EstadisticasService();
  bool _loading = true;
  Map<String, int> _conteo = {};
  Map<String, String> _nombresUbicaciones = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final conteo = await service.getConteoReservasPorUbicacion();
      final nombres = await service.getNombresUbicaciones();

      setState(() {
        _conteo = conteo;
        _nombresUbicaciones = nombres;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error cargando datos de ubicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = _conteo.entries
        .map((e) =>
            MapEntry(_nombresUbicaciones[e.key] ?? e.key, e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListSection(
          title: "🌍 Reservas por ubicación / zona",
          iconColor: Colors.lightBlueAccent,
          entries: entries,
        ),
        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: UbicacionChart(data: entries),
          ),
      ],
    );
  }
}
