import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> ensureBaseRoles() async {
    final rolesSnap = await _db.collection('Roles').get();
    if (rolesSnap.docs.isEmpty) {
      await _db.collection('Roles').doc('admin').set({
        'nombre': 'Administrador',
        'permisos': ['crear', 'editar', 'eliminar', 'ver']
      });
      await _db.collection('Roles').doc('viewer').set({
        'nombre': 'Solo lectura',
        'permisos': ['ver']
      });
    }
  }

  Future<void> ensureUserDocument() async {
    final user = _auth.currentUser!;
    final userDoc = _db.collection('Usuarios').doc(user.uid);
    final snap = await userDoc.get();

    if (!snap.exists) {
      final rolRef = _db.collection('Roles').doc('viewer');
      await userDoc.set({
        'nombre': user.displayName,
        'correo': user.email,
        'rolRef': rolRef
      });
    }
  }

  Stream<QuerySnapshot> getBahias() {
    return _db.collection('Bahias').snapshots();
  }

  Future<DocumentSnapshot> getUserRole() async {
    final user = _auth.currentUser!;
    final userDoc = await _db.collection('Usuarios').doc(user.uid).get();
    final rolRef = userDoc.get('rolRef') as DocumentReference;
    return await rolRef.get();
  }
}
