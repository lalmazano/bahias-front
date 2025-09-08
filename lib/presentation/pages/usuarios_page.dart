import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/usuarios_notifier.dart';
import './widgets/app_drawer.dart';
import '../../core/domain/entities/usuario.dart'; // <-- ajusta la ruta si difiere

class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key});
  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  final _q = TextEditingController();
  bool _soloActivos = true;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _reload() =>
      ref.read(usuariosNotifierProvider.notifier).load();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usuariosNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo'),
        onPressed: () async {
          final nuevo = await showUsuarioForm(context);
          if (nuevo != null) {
            await ref.read(usuariosNotifierProvider.notifier).create(nuevo);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario creado')),
              );
            }
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 160,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  final r = GoRouter.of(context);
                  if (r.canPop()) {
                    r.pop();
                  } else {
                    r.go('/'); // fallback al home
                  }
                },
              ),
              title: const Text('Usuarios'),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(.25),
                      cs.tertiary.withOpacity(.25)
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _q,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Buscar nombre, usuario o correo',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: (_q.text.isEmpty)
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _q.clear();
                                      setState(() {});
                                    },
                                  ),
                            filled: true,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Activos'),
                        selected: _soloActivos,
                        onSelected: (v) => setState(() => _soloActivos = v),
                        avatar: const Icon(Icons.verified_user, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (state.loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error: ${state.error}'),
                ),
              )
            else
              _UsersSliverList(q: _q.text, soloActivos: _soloActivos),
          ],
        ),
      ),
    );
  }
}

class _UsersSliverList extends ConsumerWidget {
  const _UsersSliverList({required this.q, required this.soloActivos});
  final String q;
  final bool soloActivos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(usuariosNotifierProvider);

    var users = state.data;
    final query = q.trim().toLowerCase();
    if (query.isNotEmpty) {
      users = users.where((u) {
        final s =
            '${u.nombre} ${u.apellido} ${u.username} ${u.email}'.toLowerCase();
        return s.contains(query);
      }).toList();
    }
    if (soloActivos) {
      users = users.where((u) => u.estado.toUpperCase() == 'A').toList();
    }

    if (users.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('Sin resultados')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final u = users[i];
          final initials = _ini(u.nombre, u.apellido);

          return Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [cs.primaryContainer, cs.secondaryContainer],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${u.nombre} ${u.apellido}',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text('${u.username} • ${u.email}',
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: -6,
                            children: [
                              ...u.roles.map((r) => Chip(
                                    label: Text(r),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                  )),
                              Chip(
                                label: Text(u.estado.toUpperCase() == 'A'
                                    ? 'Activo'
                                    : 'Inactivo'),
                                backgroundColor: (u.estado.toUpperCase() == 'A')
                                    ? cs.secondaryContainer
                                    : cs.errorContainer.withOpacity(.25),
                                labelStyle: TextStyle(
                                  color: (u.estado.toUpperCase() == 'A')
                                      ? cs.onSecondaryContainer
                                      : cs.error,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Acciones',
                      onSelected: (v) async {
                        final notifier =
                            ref.read(usuariosNotifierProvider.notifier);

                        if (v == 'editar') {
                          final edited =
                              await showUsuarioForm(context, initial: u);
                          if (edited != null) {
                            await notifier.update(edited);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Usuario actualizado')),
                              );
                            }
                          }
                        }

                        if (v == 'eliminar') {
                          final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Eliminar usuario'),
                                  content: Text('¿Eliminar a ${u.nombre}?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar')),
                                    FilledButton.tonal(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Eliminar')),
                                  ],
                                ),
                              ) ??
                              false;
                          if (ok) {
                            await notifier.remove(u.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Usuario eliminado')),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'ver',
                          child: ListTile(
                            leading: Icon(Icons.visibility),
                            title: Text('Ver detalle'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'editar',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Editar'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Eliminar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _ini(String n, String a) {
  final x = (n.isNotEmpty ? n[0] : '').toUpperCase();
  final y = (a.isNotEmpty ? a[0] : '').toUpperCase();
  return (x + y).isEmpty ? '?' : (x + y);
}

Future<Usuario?> showUsuarioForm(BuildContext context, {Usuario? initial}) {
  return showModalBottomSheet<Usuario>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _UsuarioForm(initial: initial),
  );
}

class _UsuarioForm extends StatefulWidget {
  const _UsuarioForm({this.initial});
  final Usuario? initial;

  @override
  State<_UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<_UsuarioForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _roles;
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    final u = widget.initial;
    _username = TextEditingController(text: u?.username ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _nombre = TextEditingController(text: u?.nombre ?? '');
    _apellido = TextEditingController(text: u?.apellido ?? '');
    _roles = TextEditingController(text: (u?.roles ?? []).join(', '));
    _activo = (u?.estado.toUpperCase() ?? 'A') == 'A';
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _nombre.dispose();
    _apellido.dispose();
    _roles.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(editing ? 'Editar usuario' : 'Nuevo usuario',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Usuario'),
              textCapitalization: TextCapitalization.characters,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Correo inválido' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _apellido,
              decoration: const InputDecoration(labelText: 'Apellido'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _roles,
              decoration: const InputDecoration(
                labelText: 'Roles (separados por coma)',
                hintText: 'ADMIN, USER',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Activo'),
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    child: Text(editing ? 'Guardar' : 'Crear'),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      final roles = _roles.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      final result = (widget.initial == null)
                          ? Usuario(
                              id: 0,
                              username: _username.text.trim().toUpperCase(),
                              email: _email.text.trim(),
                              nombre: _nombre.text.trim(),
                              apellido: _apellido.text.trim(),
                              estado: _activo ? 'A' : 'I',
                              roles: roles,
                            )
                          : widget.initial!.copyWith(
                              username: _username.text.trim().toUpperCase(),
                              email: _email.text.trim(),
                              nombre: _nombre.text.trim(),
                              apellido: _apellido.text.trim(),
                              estado: _activo ? 'A' : 'I',
                              roles: roles,
                            );

                      Navigator.pop(context, result);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension UsuarioCopy on Usuario {
  Usuario copyWith({
    int? id,
    String? username,
    String? email,
    String? nombre,
    String? apellido,
    String? estado,
    List<String>? roles,
  }) =>
      Usuario(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        nombre: nombre ?? this.nombre,
        apellido: apellido ?? this.apellido,
        estado: estado ?? this.estado,
        roles: roles ?? this.roles,
      );
}
