import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'roles_screen.dart';
import '../widgets/bahias_table.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestore = FirestoreService();
  final _auth = AuthService();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _initSetup();
  }

  Future<void> _initSetup() async {
    await _firestore.ensureBaseRoles();
    await _firestore.ensureUserDocument();
    final roleSnap = await _firestore.getUserRole();
    setState(() => userRole = roleSnap['nombre']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bahías'),
        actions: [
          if (userRole == 'Administrador')
            TextButton(
              child: Text('Roles', style: TextStyle(color: Colors.lightBlueAccent)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RolesScreen()),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text(userRole ?? '')),
          ),
          TextButton(
            onPressed: _auth.signOut,
            child: Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
      body: BahiasTable(),
    );
  }
}
