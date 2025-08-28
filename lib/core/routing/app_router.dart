import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/bays_menu_page.dart';
import '../../presentation/pages/bay_detail_page.dart';
import '../../presentation/pages/reservas_page.dart';
import '../../presentation/pages/usuarios_page.dart';
import '../../presentation/pages/roles_page.dart';
import '../../presentation/pages/reportes_page.dart';
import '../../presentation/pages/configuracion_page.dart';
import '../../presentation/state/auth_controller.dart';
import '../utils/go_router_refresh.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final authStream = ref.watch(authControllerProvider.notifier).stream;

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      final loggingIn = state.fullPath == '/login';
      if (auth.isLoading) return null;
      if (!auth.isAuthenticated && !loggingIn) return '/login';
      if (auth.isAuthenticated && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(path: '/bays', builder: (_, __) => const BaysMenuPage()),
      GoRoute(
        path: '/bays/:id',
        builder: (ctx, state) => BayDetailPage(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/reservas', builder: (_, __) => const ReservasPage()),
      GoRoute(path: '/usuarios', builder: (_, __) => const UsuariosPage()),
      GoRoute(path: '/roles', builder: (_, __) => const RolesPage()),
      GoRoute(path: '/reportes', builder: (_, __) => const ReportesPage()),
      GoRoute(path: '/configuracion', builder: (_, __) => const ConfiguracionPage()),
    ],
  );
});
