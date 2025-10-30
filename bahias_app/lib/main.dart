import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'shell/app_shell.dart';
import 'theme_provider.dart'; // ← Asegúrate que el archivo está en /lib

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Bahías Dashboard',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2ECC71),
          secondary: Color(0xFFFFC107),
          tertiary: Color(0xFF42A5F5),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F0B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2ECC71),
          secondary: Color(0xFFFFC107),
          tertiary: Color(0xFF42A5F5),
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
            return const AppShell();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
