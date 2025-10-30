import 'package:flutter/material.dart';

// Páginas del layout
import '../pages/home_summary_page.dart';   // Home (resumen)
import '../pages/bahias_page.dart';         // Grid de Bahías
import '../pages/reservas_page.dart';       // Placeholder
import '../pages/reportes_page.dart';       // Placeholder

// Pantallas que ya tenías
import '../screens/roles_screen.dart';      // Configuraciones -> Roles

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _railExpanded = true;

  final _items = const [
    _NavItem('Home', Icons.dashboard_outlined),
    _NavItem('Bahías', Icons.directions_boat_outlined),
    _NavItem('Reservas', Icons.event_available_outlined),
    _NavItem('Reportes', Icons.bar_chart_rounded),
    _NavItem('Configuraciones', Icons.settings_outlined),
  ];

  Widget _pageFor(int i) {
    switch (i) {
      case 0: return const HomeSummaryPage();
      case 1: return const BahiasPage();
      case 2: return const ReservasPage();
      case 3: return const ReportesPage();
      case 4: return RolesScreen();
      default: return const HomeSummaryPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 900;
    final isTablet = w >= 600 && w < 900;
    final showRail = isDesktop || isTablet;

    return Scaffold(
      appBar: AppBar(
        title: Text(_items[_index].label),
        backgroundColor: Colors.black,
        actions: [
          if (showRail)
            IconButton(
              tooltip: _railExpanded ? 'Colapsar menú' : 'Expandir menú',
              icon: Icon(_railExpanded ? Icons.chevron_left : Icons.chevron_right),
              onPressed: () => setState(() => _railExpanded = !_railExpanded),
            ),
        ],
      ),
      drawer: showRail ? null : Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              const ListTile(
                leading: CircleAvatar(child: Icon(Icons.directions_boat)),
                title: Text('Bahías', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Menú'),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: Icon(_items[i].icon),
                    title: Text(_items[i].label),
                    selected: _index == i,
                    onTap: () {
                      setState(() => _index = i);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
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
                  child: const Icon(Icons.directions_boat, color: Colors.greenAccent),
                ),
              ),
              trailing: IconButton(
                tooltip: _railExpanded ? 'Colapsar' : 'Expandir',
                icon: Icon(_railExpanded ? Icons.legend_toggle : Icons.menu_open),
                onPressed: () => setState(() => _railExpanded = !_railExpanded),
              ),
              destinations: _items.map((e) {
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
  const _NavItem(this.label, this.icon);
}
