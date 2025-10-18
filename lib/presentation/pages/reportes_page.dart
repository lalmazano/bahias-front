import 'package:flutter/material.dart';
import '../pages/widgets/app_drawer.dart';
import '../../data/models/bay.dart';
import '../../data/models/reservation.dart';

enum _Periodo { hoy, semana, mes }

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  // Mock: tus bahías (puedes inyectarlas desde donde las tengas)
  final bays = <Bay>[
    Bay(id: 'B1', nombre: 'Bahía 1', estado: BayStatus.libre, puestos: 3),
    Bay(id: 'B2', nombre: 'Bahía 2', estado: BayStatus.ocupada, puestos: 2),
    Bay(id: 'B3', nombre: 'Bahía 3', estado: BayStatus.mantenimiento, puestos: 4),
    Bay(id: 'B4', nombre: 'Bahía 4', estado: BayStatus.libre, puestos: 1),
  ];

  // Mock: reservas de ejemplo (cámbialas por las reales)
  final reservas = <Reservation>[
    Reservation(
      bayId: 'B1',
      start: DateTime.now().subtract(const Duration(hours: 2)),
      duration: const Duration(hours: 2),
    ),
    Reservation(
      bayId: 'B2',
      start: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      duration: const Duration(hours: 3),
    ),
    Reservation(
      bayId: 'B3',
      start: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      duration: const Duration(hours: 1, minutes: 30)),
    Reservation(
      bayId: 'B1',
      start: DateTime.now().subtract(const Duration(days: 5, hours: 4)),
      duration: const Duration(hours: 4),
    ),
  ];

  _Periodo periodo = _Periodo.hoy;

  /// Configurable: ventana operativa por día (ej. 08:00–20:00)
  final int horaInicio = 8;
  final int horaFin = 20; // exclusivo

  DateTimeRange _rangoSeleccionado(_Periodo p) {
    final now = DateTime.now();
    switch (p) {
      case _Periodo.hoy:
        final ini = DateTime(now.year, now.month, now.day, 0, 0, 0);
        final fin = ini.add(const Duration(days: 1));
        return DateTimeRange(start: ini, end: fin);
      case _Periodo.semana:
        final int weekday = now.weekday; // 1=lun ... 7=dom
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return DateTimeRange(start: startOfWeek, end: endOfWeek);
      case _Periodo.mes:
        final iniMes = DateTime(now.year, now.month, 1);
        final finMes = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: iniMes, end: finMes);
    }
  }

  /// Horas operativas totales del rango (sumando cada día 08–20)
  Duration _horasOperativasEnRango(DateTimeRange rango) {
    Duration total = Duration.zero;
    DateTime d = DateTime(rango.start.year, rango.start.month, rango.start.day);
    while (d.isBefore(rango.end)) {
      final dayStart = DateTime(d.year, d.month, d.day, horaInicio);
      final dayEnd = DateTime(d.year, d.month, d.day, horaFin);
      // Por si el rango inicia/termina a mitad de día:
      final inicio = dayStart.isBefore(rango.start) ? rango.start : dayStart;
      final fin = dayEnd.isAfter(rango.end) ? rango.end : dayEnd;
      if (fin.isAfter(inicio)) total += fin.difference(inicio);
      d = d.add(const Duration(days: 1));
    }
    return total;
  }

  /// Suma el tiempo reservado de una bahía dentro del rango, recortando intersecciones
  Duration _usoDeBayEnRango(String bayId, DateTimeRange rango) {
    Duration total = Duration.zero;

    // Ventanas diarias operativas para recortar las reservas a horario hábil
    DateTime d = DateTime(rango.start.year, rango.start.month, rango.start.day);
    while (d.isBefore(rango.end)) {
      final ventanaDia = DateTimeRange(
        start: DateTime(d.year, d.month, d.day, horaInicio),
        end: DateTime(d.year, d.month, d.day, horaFin),
      );

      for (final r in reservas.where((r) =>
          r.bayId == bayId && r.estado != ReservaEstado.cancelada)) {
        final rangoReserva = DateTimeRange(start: r.start, end: r.end);
        final inter1 = _interseccion(rangoReserva, rango);
        if (inter1 == null) continue;
        final inter2 = _interseccion(inter1, ventanaDia);
        if (inter2 == null) continue;
        total += inter2.duration;
      }
      d = d.add(const Duration(days: 1));
    }

    return total;
  }

  DateTimeRange? _interseccion(DateTimeRange a, DateTimeRange b) {
    final s = a.start.isAfter(b.start) ? a.start : b.start;
    final e = a.end.isBefore(b.end) ? a.end : b.end;
    return e.isAfter(s) ? DateTimeRange(start: s, end: e) : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rango = _rangoSeleccionado(periodo);
    final horasOperativas = _horasOperativasEnRango(rango);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filtro de período
          Row(
            children: [
              const Icon(Icons.insights_outlined),
              const SizedBox(width: 8),
              Text('Uso de bahías', style: theme.textTheme.titleLarge),
              const Spacer(),
              DropdownButton<_Periodo>(
                value: periodo,
                onChanged: (p) => setState(() => periodo = p!),
                items: const [
                  DropdownMenuItem(value: _Periodo.hoy, child: Text('Hoy')),
                  DropdownMenuItem(value: _Periodo.semana, child: Text('Semana')),
                  DropdownMenuItem(value: _Periodo.mes, child: Text('Mes')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: bays.map((b) {
                  final uso = _usoDeBayEnRango(b.id, rango);
                  final pct = horasOperativas.inMinutes == 0
                      ? 0.0
                      : uso.inMinutes / horasOperativas.inMinutes;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: _UsoRow(
                      nombre: b.nombre,
                      minutosUsados: uso.inMinutes,
                      minutosDisponibles: horasOperativas.inMinutes,
                      porcentaje: pct.clamp(0, 1),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Resumen rápido: top y promedio
          _ResumenCard(
            title: 'Resumen',
            contenido: _buildResumen(rango, horasOperativas),
          ),
        ],
      ),
    );
  }

  Widget _buildResumen(DateTimeRange rango, Duration horasOperativas) {
    if (bays.isEmpty) {
      return const Text('Sin bahías configuradas.');
    }
    final usos = bays.map((b) => _usoDeBayEnRango(b.id, rango)).toList();
    final proms = usos.isEmpty
        ? 0.0
        : usos.map((d) => d.inMinutes).reduce((a, b) => a + b) /
            (bays.length * horasOperativas.inMinutes);

    int iTop = 0;
    for (int i = 1; i < usos.length; i++) {
      if (usos[i] > usos[iTop]) iTop = i;
    }
    final topBay = bays[iTop].nombre;
    final topPct = horasOperativas.inMinutes == 0
        ? 0.0
        : usos[iTop].inMinutes / horasOperativas.inMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Promedio de uso: ${(proms * 100).toStringAsFixed(1)}%'),
        const SizedBox(height: 6),
        Text('Más usada: $topBay (${(topPct * 100).toStringAsFixed(1)}%)'),
        const SizedBox(height: 6),
        Text('Ventana analizada: '
            '${rango.start.day}/${rango.start.month} – ${rango.end.subtract(const Duration(seconds: 1)).day}/${rango.end.month}'),
        const SizedBox(height: 6),
        Text('Horario operativo: $horaInicio:00–$horaFin:00'),
      ],
    );
  }
}

class _UsoRow extends StatelessWidget {
  final String nombre;
  final int minutosUsados;
  final int minutosDisponibles;
  final double porcentaje;

  const _UsoRow({
    required this.nombre,
    required this.minutosUsados,
    required this.minutosDisponibles,
    required this.porcentaje,
  });

  @override
  Widget build(BuildContext context) {
    final minutos = minutosUsados;
    final total = minutosDisponibles;
    final pctText = '${(porcentaje * 100).toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(nombre,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Text(pctText, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: porcentaje,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_h(minutos)} de ${_h(total)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _h(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }
}

class _ResumenCard extends StatelessWidget {
  final String title;
  final Widget contenido;

  const _ResumenCard({required this.title, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.bar_chart),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 12),
            contenido,
          ],
        ),
      ),
    );
  }
}
