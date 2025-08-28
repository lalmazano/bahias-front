import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_controller.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    Widget item(IconData icon, String label, String route) {
      return ListTile(
        leading: Icon(icon, color: cs.onSurfaceVariant),
        title: Text(label),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              title: Text('Menú', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  item(Icons.grid_view_rounded, 'Bahías', '/bays'),
                  item(Icons.event_note_rounded, 'Reservas', '/reservas'),
                  item(Icons.people_alt_rounded, 'Usuarios', '/usuarios'),
                  item(Icons.shield_outlined, 'Roles', '/roles'),
                  item(Icons.bar_chart_rounded, 'Reportes', '/reportes'),
                  item(Icons.settings_rounded, 'Configuración', '/configuracion'),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
