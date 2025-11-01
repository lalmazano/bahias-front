import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:firebase_auth/firebase_auth.dart';

Future<void> generarReporteGeneral({
  DateTimeRange? rangoFechas,
  String? usuarioSeleccionado,
}) async {
  final pdf = pw.Document();
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;

  // === 🔹 Consultas principales ===
  Query<Map<String, dynamic>> query = firestore.collection('Reservas');
  if (rangoFechas != null) {
    query = query
        .where('FechaInicio', isGreaterThanOrEqualTo: rangoFechas.start)
        .where('FechaInicio', isLessThanOrEqualTo: rangoFechas.end);
  }
  if (usuarioSeleccionado != null) {
    query = query.where('UsuarioRef', isEqualTo: usuarioSeleccionado);
  }

  final snapshot = await query.get();

  // --- Conteo por estado ---
  final Map<String, int> conteoEstados = {};
  for (var doc in snapshot.docs) {
    final data = doc.data();
    dynamic estado = data['EstadoReservaRef'] ?? data['EstadoRef'];

    if (estado is DocumentReference) {
      final ref = await estado.get();
      final refData = ref.data() as Map<String, dynamic>?;
      estado = refData?['Descripcion'] ?? ref.id;
    } else if (estado is String) {
      estado = estado.split('/').last;
    } else {
      estado = 'Desconocido';
    }

    conteoEstados[estado] = (conteoEstados[estado] ?? 0) + 1;
  }
  final totalReservas = conteoEstados.values.fold<int>(0, (a, b) => a + b);

  // --- Reprogramadas ---
  final reprogramadasSnap = await firestore
      .collection('Reservas')
      .where('EsReprogramada', isEqualTo: true)
      .get();
  final totalReprogramadas = reprogramadasSnap.size;
  final totalNormales = totalReservas - totalReprogramadas;

  // --- Por Día ---
  final Map<String, int> reservasPorDia = {};
  for (var doc in snapshot.docs) {
    final fecha = (doc['FechaInicio'] as Timestamp?)?.toDate();
    if (fecha != null) {
      final dia = DateFormat('dd/MM/yyyy').format(fecha);
      reservasPorDia[dia] = (reservasPorDia[dia] ?? 0) + 1;
    }
  }

  // --- Por Usuario ---
  final Map<String, int> reservasPorUsuario = {};
  for (var doc in snapshot.docs) {
    final data = doc.data();
    final userRef = data['UsuarioRef'];
    String nombre = 'Sin nombre';
    if (userRef is DocumentReference) {
      final u = await userRef.get();
      nombre = (u.data() as Map?)?['nombre'] ?? 'Sin nombre';
    }
    reservasPorUsuario[nombre] = (reservasPorUsuario[nombre] ?? 0) + 1;
  }

  // --- Totales de Bahías y Roles ---
  final totalBahias = (await firestore.collection('Bahias').get()).size;
  final usuariosSnap = await firestore.collection('Usuarios').get();
  final roles = <String, int>{};
  for (var u in usuariosSnap.docs) {
    final rolRef = u.data()['rolRef'];
    if (rolRef is DocumentReference) {
      final rolDoc = await rolRef.get();
      final rolNombre = (rolDoc.data() as Map?)?['nombre'] ?? rolDoc.id;
      roles[rolNombre] = (roles[rolNombre] ?? 0) + 1;
    }
  }

  // ===  Creación del PDF ===
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (pw.Context context) => [
        // Encabezado institucional
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'ASEGURAMIENTO DE LA CALIDAD DE SOFTWARE',
                style: pw.TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Sistema Bahías',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.blueGrey800,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Reporte General de Reservas',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(thickness: 1),
            ],
          ),
        ),

        pw.SizedBox(height: 10),
        pw.Text(
          'Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12),
        ),
        if (rangoFechas != null)
          pw.Text(
            'Rango: ${DateFormat('dd/MM/yyyy').format(rangoFechas.start)} - ${DateFormat('dd/MM/yyyy').format(rangoFechas.end)}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        pw.Text(
          'Generado por: ${user?.email ?? "Usuario desconocido"}',
          style: pw.TextStyle(
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 15),

        // Resumen general
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(' Resumen General', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: 5),
              pw.Text('Total de Reservas: $totalReservas'),
              pw.Text('Reprogramadas: $totalReprogramadas'),
              pw.Text('Normales: $totalNormales'),
              pw.Text('Total de Bahías: $totalBahias'),
              pw.SizedBox(height: 5),
              pw.Text('Usuarios por Rol:'),
              ...roles.entries.map((r) => pw.Text('       ${r.key}: ${r.value}')),
            ],
          ),
        ),
        pw.SizedBox(height: 15),

        // Tabla de Estados
        pw.Text(' Distribución por Estado', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
        pw.SizedBox(height: 6),
        pw.Table.fromTextArray(
          headers: ['Estado', 'Cantidad', 'Porcentaje'],
          data: conteoEstados.entries
              .map((e) => [
                    e.key,
                    e.value.toString(),
                    totalReservas > 0 ? '${(e.value / totalReservas * 100).toStringAsFixed(1)}%' : '0%',
                  ])
              .toList(),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
          headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 11),
          border: pw.TableBorder.all(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
        ),

        pw.SizedBox(height: 15),
        pw.Text(' Reservas por Día', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
        pw.SizedBox(height: 6),
        pw.Table.fromTextArray(
          headers: ['Fecha', 'Cantidad'],
          data: reservasPorDia.entries
              .map((e) => [e.key, e.value.toString()])
              .toList(),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
          headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 11),
          border: pw.TableBorder.all(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
        ),

        pw.SizedBox(height: 15),
        pw.Text(' Reservas por Usuario', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
        pw.SizedBox(height: 6),
        pw.Table.fromTextArray(
          headers: ['Usuario', 'Cantidad'],
          data: reservasPorUsuario.entries
              .map((e) => [e.key, e.value.toString()])
              .toList(),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
          headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 11),
          border: pw.TableBorder.all(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
        ),

        pw.SizedBox(height: 20),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Generado automáticamente por el Sistema Bahías',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
