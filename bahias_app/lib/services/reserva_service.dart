import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🧩 Crea colecciones base y parámetros si no existen
  Future<void> ensureBaseData() async {
    // ----- Tipo_Estado -----
    final tipoEstado = _firestore.collection('Tipo_Estado');
    final estados = ['Libre', 'Ocupado', 'Mantenimiento', 'Reservado'];
    for (final e in estados) {
      final doc = await tipoEstado.doc(e).get();
      if (!doc.exists) {
        await tipoEstado.doc(e).set({'Descripcion': 'Estado $e creado automáticamente'});
      }
    }

    // ----- Estado_Reserva -----
    final estadoReserva = _firestore.collection('Estado_Reserva');
    final estadosReserva = ['Creada', 'En_uso', 'Finalizada', 'Cancelada'];
    for (final e in estadosReserva) {
      final doc = await estadoReserva.doc(e).get();
      if (!doc.exists) {
        await estadoReserva.doc(e).set({'Descripcion': 'Estado $e creado automáticamente'});
      }
    }

    // ----- Parametros -----
    final parametros = _firestore.collection('Parametros');
    final defaultParams = {
      'TiempoReserva': {
        'Minutos': 30,
        'Descripcion': 'Duración mínima de una reserva en minutos'
      },
      'TiempoReprogramacion': {
        'Minutos': 30,
        'Descripcion': 'Tiempo mínimo antes del inicio para permitir reprogramar'
      },
      'TiempoAntesReserva': {
        'Minutos': 30,
        'Descripcion': 'Tiempo antes del inicio para marcar bahías como reservadas'
      },
      'TiempoAnticipacionReserva': {
        'Minutos': 60,
        'Descripcion': 'Tiempo mínimo de anticipación para crear una reserva'
      },
      'TiempoAnticipacionReprogramacion': {
        'Minutos': 60,
        'Descripcion': 'Tiempo mínimo entre la hora original y la nueva al reprogramar'
      },
    };

    for (final entry in defaultParams.entries) {
      final ref = parametros.doc(entry.key);
      final doc = await ref.get();
      if (!doc.exists) {
        await ref.set(entry.value);
      }
    }
  }

  /// ⏱️ Obtiene cualquier parámetro en minutos
  Future<int> obtenerParametro(String nombre, {int defaultValue = 30}) async {
    try {
      final doc = await _firestore.collection('Parametros').doc(nombre).get();
      if (doc.exists) {
        final valor = doc.data()?['Minutos'];
        if (valor is int && valor > 0) return valor;
      }
      return defaultValue;
    } catch (e) {
      debugPrint("Error al leer $nombre: $e");
      return defaultValue;
    }
  }

  /// Métodos convenientes
  Future<int> obtenerTiempoMinimo() => obtenerParametro('TiempoReserva');
  Future<int> obtenerTiempoReprogramacion() => obtenerParametro('TiempoReprogramacion');
  Future<int> obtenerTiempoAntesReserva() => obtenerParametro('TiempoAntesReserva');
  Future<int> obtenerAnticipacionReserva() =>
      obtenerParametro('TiempoAnticipacionReserva', defaultValue: 60);
  Future<int> obtenerAnticipacionReprogramacion() =>
      obtenerParametro('TiempoAnticipacionReprogramacion', defaultValue: 60);

  /// 🎨 Colores según estado
  Color estadoColor(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('ocup')) return Colors.amber;
    if (e.contains('manten')) return Colors.blueAccent;
    if (e.contains('reserv')) return Colors.purpleAccent;
    if (e.contains('cancel')) return Colors.redAccent;
    return Colors.greenAccent;
  }

  /// 🟢 Crear nueva reserva
  Future<void> crearReserva(
    String usuarioId,
    Set<String> bahiasIds,
    DateTime inicio,
    DateTime fin,
    BuildContext context,
  ) async {
    try {
      final tiempoMinimo = await obtenerTiempoMinimo();
      final anticipacionMin = await obtenerAnticipacionReserva();

      final duracion = fin.difference(inicio).inMinutes;
      final ahora = DateTime.now();
      final minutosAnticipacion = inicio.difference(ahora).inMinutes;

      if (minutosAnticipacion < anticipacionMin) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Debe crear la reserva con al menos $anticipacionMin minutos de anticipación."),
          backgroundColor: Colors.orangeAccent,
        ));
        return;
      }

      if (duracion < tiempoMinimo) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("La duración mínima de una reserva es de $tiempoMinimo minutos."),
          backgroundColor: Colors.orangeAccent,
        ));
        return;
      }

      final coll = _firestore.collection('Reservas');
      final estadoRef = _firestore.collection('Estado_Reserva').doc('Creada');
      final usuarioRef = _firestore.collection('Usuarios').doc(usuarioId);
      final bahiasRefs = bahiasIds.map((id) => _firestore.collection('Bahias').doc(id)).toList();

      final last = await coll.orderBy('No_Reserva', descending: true).limit(1).get();
      final noReserva = last.docs.isEmpty ? 1 : (last.docs.first['No_Reserva'] ?? 0) + 1;

      await coll.add({
        'No_Reserva': noReserva,
        'UsuarioRef': usuarioRef,
        'BahiasRefs': bahiasRefs,
        'FechaInicio': Timestamp.fromDate(inicio),
        'FechaFin': Timestamp.fromDate(fin),
        'EstadoReservaRef': estadoRef,
        'Reprogramada': false,
        'FechaCreacion': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Reserva creada correctamente."),
        backgroundColor: Colors.greenAccent,
      ));
    } catch (e) {
      debugPrint("Error al crear reserva: $e");
    }
  }

  /// 🕓 Reprogramar reserva
  Future<void> reprogramarReserva(
    String id,
    DateTime inicioAnt,
    DateTime finAnt,
    DateTime nuevoInicio,
    DateTime nuevoFin,
    BuildContext context,
  ) async {
    try {
      final tiempoMinimo = await obtenerTiempoMinimo();
      final anticipacionReprog = await obtenerAnticipacionReprogramacion();
      final tiempoReprog = await obtenerTiempoReprogramacion();

      final ahora = DateTime.now();
      final duracion = nuevoFin.difference(nuevoInicio).inMinutes;
      final minutosRestantes = inicioAnt.difference(ahora).inMinutes;
      final diferenciaNueva = nuevoInicio.difference(inicioAnt).inMinutes;

      if (minutosRestantes < tiempoReprog) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Solo se puede reprogramar con $tiempoReprog minutos de anticipación."),
          backgroundColor: Colors.redAccent,
        ));
        return;
      }

      if (diferenciaNueva < anticipacionReprog) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("La nueva hora debe ser al menos $anticipacionReprog minutos después de la original."),
          backgroundColor: Colors.orangeAccent,
        ));
        return;
      }

      if (duracion < tiempoMinimo) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("La nueva reserva debe durar al menos $tiempoMinimo minutos."),
          backgroundColor: Colors.orangeAccent,
        ));
        return;
      }

      await _firestore.collection('Reservas').doc(id).update({
        'FechaInicioAnterior': Timestamp.fromDate(inicioAnt),
        'FechaFinAnterior': Timestamp.fromDate(finAnt),
        'FechaInicio': Timestamp.fromDate(nuevoInicio),
        'FechaFin': Timestamp.fromDate(nuevoFin),
        'Reprogramada': true,
        'FechaReprogramacion': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Reserva reprogramada correctamente."),
        backgroundColor: Colors.orangeAccent,
      ));
    } catch (e) {
      debugPrint("Error al reprogramar reserva: $e");
    }
  }

  /// ❌ Cancelar reserva
  Future<void> cancelarReserva(
    String id,
    List<DocumentReference> bahiasRefs,
    BuildContext context,
  ) async {
    try {
      final libreRef = _firestore.collection('Tipo_Estado').doc('Libre');
      final canceladaRef = _firestore.collection('Estado_Reserva').doc('Cancelada');

      // Cambiar las bahías a libre
      for (final ref in bahiasRefs) {
        await ref.update({'EstadoRef': libreRef});
      }

      // Actualizar la reserva
      await _firestore.collection('Reservas').doc(id).update({
        'EstadoReservaRef': canceladaRef,
        'FechaCancelacion': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Reserva cancelada correctamente."),
        backgroundColor: Colors.redAccent,
      ));
    } catch (e) {
      debugPrint("Error al cancelar reserva: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al cancelar: $e"),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  /// 🔄 Actualización automática de estados
  Future<void> actualizarEstadosAutomaticos() async {
    try {
      final ahora = DateTime.now();
      final tiempoAntes = await obtenerTiempoAntesReserva();
      final reservasSnap = await _firestore.collection('Reservas').get();

      final colEstadosReserva = _firestore.collection('Estado_Reserva');
      final colEstadosBahia = _firestore.collection('Tipo_Estado');

      final docEnUso = colEstadosReserva.doc('En_uso');
      final docFinalizada = colEstadosReserva.doc('Finalizada');
      final estadoLibre = colEstadosBahia.doc('Libre');
      final estadoReservado = colEstadosBahia.doc('Reservado');
      final estadoOcupado = colEstadosBahia.doc('Ocupado');

      for (final doc in reservasSnap.docs) {
        final data = doc.data();
        final reservaId = doc.id;
        final inicio = (data['FechaInicio'] as Timestamp).toDate();
        final fin = (data['FechaFin'] as Timestamp).toDate();
        final estadoReservaRef = data['EstadoReservaRef'] as DocumentReference?;
        final estadoActual = estadoReservaRef?.id ?? '';
        final bahiasRefs = (data['BahiasRefs'] as List?)?.cast<DocumentReference>() ?? [];

        if (estadoActual == 'Cancelada') continue;

        // 1️⃣ Antes del inicio (bahías reservadas)
        if (ahora.isAfter(inicio.subtract(Duration(minutes: tiempoAntes))) &&
            ahora.isBefore(inicio) &&
            estadoActual == 'Creada') {
          for (final ref in bahiasRefs) {
            await ref.update({'EstadoRef': estadoReservado});
          }
        }

        // 2️⃣ Durante el rango (bahías ocupadas)
        if (ahora.isAfter(inicio) && ahora.isBefore(fin)) {
          if (estadoActual != 'En_uso') {
            await _firestore.collection('Reservas').doc(reservaId).update({
              'EstadoReservaRef': docEnUso,
            });
            for (final ref in bahiasRefs) {
              await ref.update({'EstadoRef': estadoOcupado});
            }
          }
        }

        // 3️⃣ Después del fin (bahías liberadas)
        if (ahora.isAfter(fin) && estadoActual != 'Finalizada') {
          await _firestore.collection('Reservas').doc(reservaId).update({
            'EstadoReservaRef': docFinalizada,
            'FechaFinalizacion': Timestamp.now(),
          });
          for (final ref in bahiasRefs) {
            await ref.update({'EstadoRef': estadoLibre});
          }
        }
      }
    } catch (e) {
      debugPrint("Error en actualización automática: $e");
    }
  }
}
