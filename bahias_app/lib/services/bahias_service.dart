import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BahiasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔧 Crea colecciones base y bahías por defecto
  Future<void> ensureDefaultData() async {
    await _ensureDefaultUbicaciones();

    final coll = _firestore.collection('Bahias');
    final tipoRefDefault = _firestore.collection('Tipo_Bahia').doc('General');
    final estadoRefDefault = _firestore.collection('Tipo_Estado').doc('Libre');
    final ubicacionRefDefault =
        _firestore.collection('Ubicacion').doc('Ubicacion 1');

    for (int i = 1; i <= 35; i++) {
      final docId = i.toString().padLeft(2, '0');
      final docRef = coll.doc(docId);
      final snap = await docRef.get();

      if (!snap.exists) {
        await docRef.set({
          'No_Bahia': i,
          'Nombre': 'Bahía $i',
          'TipoRef': tipoRefDefault,
          'EstadoRef': estadoRefDefault,
          'UbicacionRef': ubicacionRefDefault,
        });
      } else {
        await ensureCamposBahia(docRef, snap);
      }
    }
  }

  /// 🧩 Crear ubicaciones base si no existen
  Future<void> _ensureDefaultUbicaciones() async {
    final coll = _firestore.collection('Ubicacion');
    for (int i = 1; i <= 3; i++) {
      final docId = 'Ubicacion $i';
      final docRef = coll.doc(docId);
      final snap = await docRef.get();
      if (!snap.exists) {
        await docRef.set({
          'Nombre': 'Ubicación $i',
          'Descripcion': 'Zona o área base número $i',
        });
      }
    }
  }

  /// 🔍 Verifica y crea campos faltantes en una bahía existente
  Future<void> ensureCamposBahia(
    DocumentReference<Map<String, dynamic>> docRef,
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) async {
    final data = snap.data() ?? {};
    final updates = <String, dynamic>{};

    final tipoRefDefault = _firestore.collection('Tipo_Bahia').doc('General');
    final estadoRefDefault = _firestore.collection('Tipo_Estado').doc('Libre');
    final ubicacionRefDefault =
        _firestore.collection('Ubicacion').doc('Ubicacion 1');

    if (!data.containsKey('No_Bahia')) {
      final idNum = int.tryParse(docRef.id) ?? 0;
      updates['No_Bahia'] = idNum;
    }

    if (!data.containsKey('Nombre')) {
      updates['Nombre'] = 'Bahía ${data['No_Bahia'] ?? docRef.id}';
    }

    if (!data.containsKey('TipoRef') || data['TipoRef'] == null) {
      updates['TipoRef'] = tipoRefDefault;
    }

    if (!data.containsKey('EstadoRef') || data['EstadoRef'] == null) {
      updates['EstadoRef'] = estadoRefDefault;
    }

    if (!data.containsKey('UbicacionRef') || data['UbicacionRef'] == null) {
      updates['UbicacionRef'] = ubicacionRefDefault;
    }

    if (updates.isNotEmpty) {
      await docRef.update(updates);
    }
  }

  /// 🎨 Define color según el estado
  Color estadoColor(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('ocup')) return const Color(0xFFFFC107);
    if (e.contains('manten')) return const Color(0xFF42A5F5);
    if (e.contains('reserv')) return const Color(0xFF9C27B0);
    return const Color(0xFF2ECC71);
  }

  /// 📡 Stream en tiempo real de todas las bahías
  Stream<QuerySnapshot<Map<String, dynamic>>> streamBahias() {
    return _firestore.collection('Bahias').orderBy('No_Bahia').snapshots();
  }

  /// 🧠 Garantiza referencias válidas antes de usar
  Future<List<DocumentSnapshot?>> ensureReferences(
    DocumentReference? tipoRef,
    DocumentReference? estadoRef,
    DocumentReference? ubicacionRef,
  ) async {
    tipoRef ??= _firestore.collection('Tipo_Bahia').doc('General');
    estadoRef ??= _firestore.collection('Tipo_Estado').doc('Libre');
    ubicacionRef ??=
        _firestore.collection('Ubicacion').doc('Ubicacion 1');

    return [
      await tipoRef.get(),
      await estadoRef.get(),
      await ubicacionRef.get()
    ];
  }

  /// 🧰 Cambiar estado a Mantenimiento o Libre
  Future<void> setEstado(String estado, List<String> ids) async {
    final ref = _firestore.collection('Tipo_Estado').doc(estado);
    for (final id in ids) {
      await _firestore.collection('Bahias').doc(id).update({'EstadoRef': ref});
    }
  }

  /// 🗑️ Eliminar bahías seleccionadas (solo las que no son protegidas)
  Future<void> deleteBahias(List<String> ids) async {
    for (final id in ids) {
      final doc = await _firestore.collection('Bahias').doc(id).get();
      final no = doc.data()?['No_Bahia'] ?? 0;
      if (no > 35) {
        await doc.reference.delete();
      }
    }
  }

  /// ➕ Agregar nueva bahía (con referencias por defecto)
  Future<void> addNewBahia() async {
    final coll = _firestore.collection('Bahias');
    final total = (await coll.get()).size;

    final tipoRef = _firestore.collection('Tipo_Bahia').doc('General');
    final estadoRef = _firestore.collection('Tipo_Estado').doc('Libre');
    final ubicacionRef =
        _firestore.collection('Ubicacion').doc('Ubicacion 1');

    await coll.doc((total + 1).toString().padLeft(2, '0')).set({
      'No_Bahia': total + 1,
      'Nombre': 'Bahía ${total + 1}',
      'TipoRef': tipoRef,
      'EstadoRef': estadoRef,
      'UbicacionRef': ubicacionRef,
    });
  }

  /// 🔄 Cambiar tipo de una lista de bahías
  Future<void> updateTipo(List<String> ids, String nuevoTipo) async {
    final tipoRef = _firestore.collection('Tipo_Bahia').doc(nuevoTipo);
    for (final id in ids) {
      await _firestore.collection('Bahias').doc(id).update({
        'TipoRef': tipoRef,
      });
    }
  }

  /// 📍 Cambiar ubicación de una lista de bahías
  Future<void> updateUbicacion(List<String> ids, String nuevaUbicacion) async {
    final ubicacionRef =
        _firestore.collection('Ubicacion').doc(nuevaUbicacion);
    for (final id in ids) {
      await _firestore.collection('Bahias').doc(id).update({
        'UbicacionRef': ubicacionRef,
      });
    }
  }
}
