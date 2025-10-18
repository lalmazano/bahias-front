import 'package:flutter/material.dart';
import '../pages/widgets/app_drawer.dart';
import '../../data/models/bay.dart';
import '../../data/models/reservation.dart';
import '../../data/models/estado_bahia.dart';
import '../../services/bahia_service.dart';
import '../../services/reserva_service.dart';
import '../../services/estado_bahia_service.dart';

enum _Periodo { hoy, semana, mes }

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  final BahiaService _bService = BahiaService();
  final ReservaService _rService = ReservaService();
  final EstadoBahiaService _eService = EstadoBahiaService();

  List<Bay> bays = [];
  List<Reservation> reservas = [];
  Map<int, EstadoBahia> estados = {};

  _Periodo periodo = _Periodo.hoy;
  final int horaInicio = 8;
  final int horaFin = 20;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedBays = await _bService.getAll();
      final fetchedReservas = await _rService.getAll();
      final fetchedEstados = await _eService.getAll();

      setState(() {
        bays = fetchedBays;
        reservas = fetchedReservas;
        estados = {for (var e in fetchedEstados) e.idEstado: e};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  DateTimeRange _rangoSeleccionado(_Periodo p) {
    final now = DateTime.now();
    switch (p) {
      case _Periodo.hoy:
        final ini = DateTime(now.year, now.month, now.day, 0, 0, 0);
        final fin = ini.add(const Duration(days: 1));
        return DateTimeRange(start: ini, end: fin);
      case _Periodo.semana:
        final int weekday = now.weekday;
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

  Duration _horasOperativasEnRango(DateTimeRange rango) {
    Duration total = Duration.zero;
    DateTime d = DateTime(rango.start.year, rango.start.month, rango.start.day);
    while (d.isBefore(rango.end)) {
      final dayStart = DateTime(d.year, d.month, d.day, horaInicio);
      final dayEnd = DateTime(d.year, d.month, d.day, horaFin);
      final inicio = dayStart.isBefore(rango.start) ? rango.start : dayStart;
      final fin = dayEnd.isAfter(rango.end) ? rango.end : dayEnd;
      if (fin.isAfter(inicio)) total += fin.difference(inicio);
      d = d.add(const Duration(days: 1));
    }
    return total;
  }

  Duration _usoDeBayEnRango(int bayId, DateTimeRange rango) {
    Duration total = Duration.zero;

    DateTime d = DateTime(rango.start.year, rango.start.month, rango.start.day);
    while (d.isBefore(rango.end)) {
      final ventanaDia = DateTimeRange(
        start: DateTime(d.year, d.month, d.day, horaInicio),
        end: DateTime(d.year, d.month, d.day, horaFin),
      );

      for (final r in reservas) {
        if (r.bahia == null || r.bahia!.isEmpty) continue;

        for (final b in r.bahia!) {
          if (b.idBahia == bayId) {
            final rangoReserva = DateTimeRange(
              start: r.inicioTs,
              end: r.finTs,
            );

            final inter1 = _interseccion(rangoReserva, rango);
            if (inter1 == null) continue;

            final inter2 = _interseccion(inter1, ventanaDia);
            if (inter2 == null) continue;

            total += inter2.duration;
          }
        }
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

  Color colorPorEstado(int idEstado) {
    switch (idEstado) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.pink;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reportes')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    final rango = _rangoSeleccionado(periodo);
    final horasOperativas = _horasOperativasEnRango(rango);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes de Bahías')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Leyenda de colores
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: estados.entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 6,
                    backgroundColor: colorPorEstado(e.key),
                  ),
                  const SizedBox(width: 6),
                  Text(e.value.nombre,
                      style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

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
                  final uso = _usoDeBayEnRango(b.idBahia, rango);
                  final pct = horasOperativas.inMinutes == 0
                      ? 0.0
                      : uso.inMinutes / horasOperativas.inMinutes;
                  final estadoNombre =
                      estados[b.idEstado]?.nombre ?? 'Sin estado';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: _UsoRow(
                      nombre: 'Bahía ${b.idBahia} ($estadoNombre)',
                      minutosUsados: uso.inMinutes,
                      minutosDisponibles: horasOperativas.inMinutes,
                      porcentaje: pct.clamp(0, 1),
                      color: colorPorEstado(b.idEstado),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
      return const Text('Sin bahías registradas.');
    }

    final usos = bays.map((b) => _usoDeBayEnRango(b.idBahia, rango)).toList();
    final proms = usos.isEmpty
        ? 0.0
        : usos.map((d) => d.inMinutes).reduce((a, b) => a + b) /
            (bays.length * horasOperativas.inMinutes);

    int iTop = 0;
    for (int i = 1; i < usos.length; i++) {
      if (usos[i] > usos[iTop]) iTop = i;
    }
    final topBay = 'Bahía ${bays[iTop].idBahia}';
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
        Text(
            'Ventana: ${rango.start.day}/${rango.start.month} – ${rango.end.subtract(const Duration(seconds: 1)).day}/${rango.end.month}'),
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
  final Color color;

  const _UsoRow({
    required this.nombre,
    required this.minutosUsados,
    required this.minutosDisponibles,
    required this.porcentaje,
    required this.color,
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
            color: color,
            backgroundColor: color.withOpacity(0.2),
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
