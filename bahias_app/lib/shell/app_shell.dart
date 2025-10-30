import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Páginas del layout
import '../pages/home_summary_page.dart';
import '../pages/bahias_page.dart';
import '../pages/reservas_page.dart';
import '../pages/reportes_page.dart';
import '../screens/roles_screen.dart';

// Servicio Firestore
import '../services/firestore_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _railExpanded = true;
  bool _loading = true;
  Map<String, dynamic>? _rolData;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirestoreService();

  final List<_NavItem> _allItems = const [
    _NavItem('Home', Icons.dashboard_outlined, permiso: 'ver'),
    _NavItem('Bahías', Icons.directions_boat_outlined, permiso: 'ver'),
    _NavItem('Reservas', Icons.event_available_outlined, permiso: 'crear'),
    _NavItem('Reportes', Icons.bar_chart_rounded, permiso: 'generar_reportes'),
    _NavItem('Configuraciones', Icons.settings_outlined, permiso: 'editar'),
  ];

  List<_NavItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final rolDoc = await _firestore.getUserRole();
      final rolData = rolDoc.data() as Map<String, dynamic>;
      setState(() {
        _rolData = rolData;
        final permisos = List<String>.from(rolData['permisos'] ?? []);
        _filteredItems =
            _allItems.where((item) => permisos.contains(item.permiso)).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error al obtener el rol del usuario: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _pageFor(int i) {
    switch (_filteredItems[i].label) {
      case 'Home':
        return const HomeSummaryPage();
      case 'Bahías':
        return const BahiasPage();
      case 'Reservas':
        return const ReservasPage();
      case 'Reportes':
        return const ReportesPage();
      case 'Configuraciones':
        return RolesScreen();
      default:
        return const HomeSummaryPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 900;
    final isTablet = w >= 600 && w < 900;
    final showRail = isDesktop || isTablet;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_filteredItems[_index].label),
        backgroundColor: Colors.black,
        actions: [
          if (_rolData != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  _rolData!['nombre'] ?? '',
                  style: const TextStyle(
                      color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: showRail
          ? null
          : Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        _auth.currentUser?.displayName ?? 'Usuario',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_rolData?['nombre'] ?? 'Rol desconocido'),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredItems.length,
                        itemBuilder: (_, i) => ListTile(
                          leading: Icon(_filteredItems[i].icon),
                          title: Text(_filteredItems[i].label),
                          selected: _index == i,
                          onTap: () {
                            setState(() => _index = i);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text("Cerrar sesión",
                          style: TextStyle(color: Colors.redAccent)),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ),
      body: Row(
        children: [
          if (showRail) ...[
            NavigationRail(
              extended: _railExpanded,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              backgroundColor: const Color(0xFF111511),
              indicatorColor: Colors.greenAccent.withOpacity(0.15),
              selectedIconTheme: const IconThemeData(color: Colors.greenAccent),
              selectedLabelTextStyle: const TextStyle(color: Colors.greenAccent),
              leading: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: CircleAvatar(
                  backgroundColor: Colors.greenAccent.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.greenAccent),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: _railExpanded ? 'Colapsar' : 'Expandir',
                    icon: Icon(_railExpanded
                        ? Icons.legend_toggle
                        : Icons.menu_open),
                    onPressed: () =>
                        setState(() => _railExpanded = !_railExpanded),
                  ),
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    icon:
                        const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: _logout,
                  ),
                ],
              ),
              destinations: _filteredItems.map((e) {
                return NavigationRailDestination(
                  icon: Icon(e.icon, color: Colors.white70),
                  selectedIcon: Icon(e.icon, color: Colors.greenAccent),
                  label: Text(e.label),
                );
              }).toList(),
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(child: _pageFor(_index)),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String permiso;
  const _NavItem(this.label, this.icon, {required this.permiso});
}
