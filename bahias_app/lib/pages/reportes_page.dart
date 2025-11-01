import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔹 Importa los reportes
import './reports/reporte_usuarios.dart';
import './reports/reporte_estados.dart';
import './reports/reporte_reprogramadas.dart';
import './reports/reporte_dias.dart';

// 🔹 Importa la función de exportación
import './reports/exportar_reportes.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  final _firestore = FirebaseFirestore.instance;
  DateTimeRange? _rangoSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '📊 Reportes de Reservas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView( // ✅ Corrige RenderBox was not laid out
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Selector de rango de fechas
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(_rangoSeleccionado == null
                    ? 'Seleccionar rango de fechas'
                    : 'Rango: ${_formatearRango(_rangoSeleccionado!)}'),
                onPressed: () async {
                  final rango = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                    initialDateRange: _rangoSeleccionado,
                  );
                  if (rango != null) {
                    setState(() => _rangoSeleccionado = rango);
                  }
                },
              ),
              const SizedBox(height: 25),

              const _TituloSeccion('Reservas por Usuario'),
              const SizedBox(height: 12),
              ReporteReservasPorUsuario(rango: _rangoSeleccionado),
              const SizedBox(height: 30),

              const _TituloSeccion('Reservas por Estado'),
              const SizedBox(height: 12),
              ReporteEstados(),
              const SizedBox(height: 30),

              const _TituloSeccion('Reservas Reprogramadas'),
              const SizedBox(height: 12),
              ReporteReprogramadas(),
              const SizedBox(height: 30),

              const _TituloSeccion('Reservas por Día'),
              const SizedBox(height: 12),
              ReporteReservasPorDia(rango: _rangoSeleccionado),
              const SizedBox(height: 40),

              // 🔹 Botón para generar PDF
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: const Text(
                    'Exportar Reporte General',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await generarReporteGeneral(
                      rangoFechas: _rangoSeleccionado,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Formatea el rango de fechas
  String _formatearRango(DateTimeRange rango) {
    return "${rango.start.day}/${rango.start.month}/${rango.start.year} - "
        "${rango.end.day}/${rango.end.month}/${rango.end.year}";
  }
}

/// 🔸 Título reutilizable
class _TituloSeccion extends StatelessWidget {
  final String texto;
  const _TituloSeccion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
