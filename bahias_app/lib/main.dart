import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return MaterialApp(
      title: 'Bahías Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0B0F0B),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2ECC71),   // verde
    secondary: Color(0xFFFFC107), // amarillo
    tertiary: Color(0xFF42A5F5),  // azul
  ),
),

      home: StreamBuilder(
        stream: auth.userChanges,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasData) {
            return const AppShell();      // ← Sidebar con páginas
          }
          return const LoginScreen();     // ← Pantalla de login
        },
      ),
    );
  }
}
