import 'package:cloud_firestore/cloud_firestore.dart';

class ParametrosService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'Parametros';

  Stream<QuerySnapshot<Map<String, dynamic>>> streamParametros() {
    return _db.collection(_collection).orderBy(FieldPath.documentId).snapshots();
  }

  Future<Map<String, dynamic>?> getParametro(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> createParametro({
    required String id,
    required int minutos,
    String? descripcion,
  }) async {
    await _db.collection(_collection).doc(id).set({
      'Minutos': minutos,
      if (descripcion != null) 'Descripcion': descripcion,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: false));
  }

  Future<void> updateParametro({
    required String id,
    int? minutos,
    String? descripcion,
  }) async {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (minutos != null) data['Minutos'] = minutos;
    if (descripcion != null) data['Descripcion'] = descripcion;
    await _db.collection(_collection).doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteParametro(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
