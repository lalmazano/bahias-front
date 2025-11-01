import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  final GlobalKey _chartEstadoKey = GlobalKey();
  final GlobalKey _chartDiaKey = GlobalKey();
  Map<String, int> _dataEstados = {};

  // 🔹 Filtros
  DateTimeRange? _rangoFechas;
  String? _usuarioSeleccionado;
  List<Map<String, dynamic>> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Usuarios').get();
    setState(() {
      _usuarios = snapshot.docs.map((e) {
        final data = e.data();
        return {
          'id': e.reference.path, // ejemplo: "Usuarios/abc123"
          'nombre': data['Nombre'] ?? data['nombre'] ?? 'Sin nombre',
        };
      }).toList();
    });
  }

  /// Captura widget como imagen PNG
  Future<Uint8List> _capturarWidget(GlobalKey key) async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Generar PDF con gráficos
  Future<void> _generarPDF() async {
    final pdf = pw.Document();

    final imgEstados = await _capturarWidget(_chartEstadoKey);
    final imgDias = await _capturarWidget(_chartDiaKey);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text('📊 Reporte General de Reservas',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text(
            'Generado el: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          if (_rangoFechas != null)
            pw.Text(
                'Rango: ${DateFormat('dd/MM/yyyy').format(_rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(_rangoFechas!.end)}'),
          if (_usuarioSeleccionado != null)
            pw.Text('Usuario: $_usuarioSeleccionado'),
          pw.SizedBox(height: 20),
          pw.Text('Distribución por Estado',
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Image(pw.MemoryImage(imgEstados)),
          pw.SizedBox(height: 20),
          pw.Text('Reservas por Día',
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Image(pw.MemoryImage(imgDias)),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void _actualizarDatos(Map<String, int> nuevosDatos) {
    setState(() => _dataEstados = nuevosDatos);
  }

  Future<void> _seleccionarRango() async {
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _rangoFechas,
    );
    if (rango != null) {
      setState(() => _rangoFechas = rango);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Reportes Generales'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar a PDF',
            onPressed: _dataEstados.isEmpty ? null : _generarPDF,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔸 FILTROS
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Filtros',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      // 🔹 Filtro de fechas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _rangoFechas == null
                                ? 'Sin rango seleccionado'
                                : 'Del ${DateFormat('dd/MM/yyyy').format(_rangoFechas!.start)} '
                                    'al ${DateFormat('dd/MM/yyyy').format(_rangoFechas!.end)}',
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.date_range),
                            label: const Text('Seleccionar rango'),
                            onPressed: _seleccionarRango,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 🔹 Filtro por usuario
                      DropdownButtonFormField<String>(
                        value: _usuarioSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Todos los usuarios')),
                          ..._usuarios.map((u) => DropdownMenuItem(
                                value: u['id'],
                                child: Text(u['nombre']),
                              )),
                        ],
                        onChanged: (valor) =>
                            setState(() => _usuarioSeleccionado = valor),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔸 GRÁFICOS
              RepaintBoundary(
                key: _chartEstadoKey,
                child: _ReporteReservasPorEstado(
                  onDataReady: _actualizarDatos,
                  rango: _rangoFechas,
                  usuarioRef: _usuarioSeleccionado,
                ),
              ),
              const SizedBox(height: 30),
              RepaintBoundary(
                key: _chartDiaKey,
                child: _ReporteReservasPorDia(
                  rango: _rangoFechas,
                  usuarioRef: _usuarioSeleccionado,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// 🔹 Reporte 1: Reservas por Estado
//
class _ReporteReservasPorEstado extends StatelessWidget {
  final Function(Map<String, int>) onDataReady;
  final DateTimeRange? rango;
  final String? usuarioRef;

  const _ReporteReservasPorEstado({
    required this.onDataReady,
    this.rango,
    this.usuarioRef,
  });

  Color _colorPorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'creada':
        return Colors.blueAccent;
      case 'en_uso':
        return Colors.green;
      case 'finalizada':
        return Colors.purple;
      case 'cancelada':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Future<Map<String, int>> _getDatos() async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Reservas');

    // 🔸 Aplicar filtros
    if (rango != null) {
      query = query
          .where('FechaInicio', isGreaterThanOrEqualTo: rango!.start)
          .where('FechaInicio', isLessThanOrEqualTo: rango!.end);
    }

    if (usuarioRef != null) {
      final ref = FirebaseFirestore.instance.doc(usuarioRef!);
      query = query.where('UsuarioRef', isEqualTo: ref);
    }

    final snapshot = await query.get();
    final Map<String, int> estados = {};

    for (var doc in snapshot.docs) {
      final info = doc.data();
      dynamic estadoReservaRef = info['EstadoReservaRef'];
      dynamic estadoRef = info['EstadoRef'];
      String estado = 'Desconocido';

      if (estadoReservaRef != null) {
        if (estadoReservaRef is DocumentReference) {
          final refData = await estadoReservaRef.get();
          estado = refData.id;
        } else if (estadoReservaRef is String) {
          final partes = estadoReservaRef.split('/');
          estado = partes.isNotEmpty ? partes.last : 'Desconocido';
        }
      } else if (estadoRef != null) {
        if (estadoRef is DocumentReference) {
          final refData = await estadoRef.get();
          estado = refData.id;
        } else if (estadoRef is String) {
          final partes = estadoRef.split('/');
          estado = partes.isNotEmpty ? partes.last : 'Desconocido';
        }
      }

      estados[estado] = (estados[estado] ?? 0) + 1;
    }

    onDataReady(estados);
    return estados;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _getDatos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final items = data.entries.toList();

        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reservas por Estado',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                if (items.isEmpty)
                  const Text('No hay datos para mostrar'),
                if (items.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: PieChart(
                      PieChartData(
                        sections: items
                            .map(
                              (e) => PieChartSectionData(
                                value: e.value.toDouble(),
                                color: _colorPorEstado(e.key),
                                title: '${e.key}\n${e.value}',
                                radius: 70,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//
// 🔹 Reporte 2: Reservas por Día
//
class _ReporteReservasPorDia extends StatelessWidget {
  final DateTimeRange? rango;
  final String? usuarioRef;

  const _ReporteReservasPorDia({this.rango, this.usuarioRef});

  Future<Map<String, int>> _getDatos() async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Reservas');

    if (rango != null) {
      query = query
          .where('FechaInicio', isGreaterThanOrEqualTo: rango!.start)
          .where('FechaInicio', isLessThanOrEqualTo: rango!.end);
    }

    if (usuarioRef != null) {
      final ref = FirebaseFirestore.instance.doc(usuarioRef!);
      query = query.where('UsuarioRef', isEqualTo: ref);
    }

    final snapshot = await query.get();
    final Map<String, int> porDia = {};

    for (var doc in snapshot.docs) {
      final info = doc.data();
      final fecha = (info['FechaInicio'] ?? info['FechaFin']) as Timestamp?;
      if (fecha != null) {
        final dia = DateFormat('dd/MM').format(fecha.toDate());
        porDia[dia] = (porDia[dia] ?? 0) + 1;
      }
    }

    return porDia;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _getDatos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final dias = data.keys.toList();
        final valores = data.values.toList();

        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reservas por Día',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                if (dias.isEmpty)
                  const Text('No hay datos para mostrar'),
                if (dias.isNotEmpty)
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                return i < dias.length
                                    ? Text(dias[i],
                                        style:
                                            const TextStyle(fontSize: 10))
                                    : const SizedBox();
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(dias.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: valores[i].toDouble(),
                                width: 15,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
