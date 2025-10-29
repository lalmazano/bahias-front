import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahías Dashboard',
      theme: ThemeData.dark(),
      home: StreamBuilder(
        stream: _authService.userChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DashboardScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}