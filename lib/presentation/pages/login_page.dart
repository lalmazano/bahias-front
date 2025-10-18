import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_controller.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String _mapAuthError(String raw) {
    final lower = raw.toLowerCase();
    // Detecta el status en el mensaje de excepción: "HTTP 401: ..."
    if (lower.contains('http 401')) {
      return 'No tienes acceso (401). Verifica tus credenciales o permisos.';
    }
    // Mensaje por defecto
    return 'No se pudo iniciar sesión. $raw';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authControllerProvider.notifier).login(
          _userCtrl.text.trim(),
          _passCtrl.text,
        );

    final auth = ref.read(authControllerProvider);

    if (auth.isAuthenticated) {
      if (mounted) context.go('/');
      return;
    }

    if (auth.error != null && mounted) {
      final msg = _mapAuthError(auth.error!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    // Breakpoints simples
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final horizontalPadding = isDesktop ? 32.0 : 16.0;

    // Si hay error, lo mapeamos para el texto bajo el botón
    final String? uiError =
        auth.error != null ? _mapAuthError(auth.error!) : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7FBF3), Color(0xFFEFF6EA)],
          ),
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 12),
                        Text('Iniciar sesión',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),

                        // Usuario
                        TextFormField(
                          controller: _userCtrl,
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingresa tu usuario'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Contraseña
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                              icon: Icon(_obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Ingresa tu contraseña'
                              : null,
                        ),
                        const SizedBox(height: 18),

                        // Botón
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: auth.isLoading ? null : _submit,
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2.6))
                                : const Text('Entrar'),
                          ),
                        ),

                        // Error visible debajo (ya mapeado 401)
                        if (uiError != null) ...[
                          const SizedBox(height: 12),
                          Text(uiError,
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
