import 'package:flutter/material.dart';
import './widgets/app_drawer.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  _RolesPageState createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  final List<Map<String, dynamic>> _roles = [
    {'roleName': 'Admin', 'permissions': ['Acceso total', 'Editar bahías', 'Ver reportes']},
    {'roleName': 'Usuario', 'permissions': ['Ver bahías', 'Reservar bahías']},
    {'roleName': 'Gerente', 'permissions': ['Ver reportes', 'Editar bahías']},
  ];

  // Método para agregar un nuevo rol
  void _addRole() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController roleNameController = TextEditingController();
        final TextEditingController permissionController = TextEditingController();

        return AlertDialog(
          title: const Text('Agregar Nuevo Rol'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roleNameController,
                decoration: const InputDecoration(labelText: 'Nombre del rol'),
              ),
              TextField(
                controller: permissionController,
                decoration: const InputDecoration(labelText: 'Permisos (separados por coma)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _roles.add({
                    'roleName': roleNameController.text,
                    'permissions': permissionController.text.split(','),
                  });
                });
                Navigator.of(context).pop();
              },
              child: const Text('Agregar Rol'),
            ),
          ],
        );
      },
    );
  }

  // Método para editar un rol
  void _editRole(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController roleNameController = TextEditingController(text: _roles[index]['roleName']);
        final TextEditingController permissionController = TextEditingController(text: _roles[index]['permissions'].join(','));

        return AlertDialog(
          title: const Text('Editar Rol'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roleNameController,
                decoration: const InputDecoration(labelText: 'Nombre del rol'),
              ),
              TextField(
                controller: permissionController,
                decoration: const InputDecoration(labelText: 'Permisos (separados por coma)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _roles[index]['roleName'] = roleNameController.text;
                  _roles[index]['permissions'] = permissionController.text.split(',');
                });
                Navigator.of(context).pop();
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roles')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de roles y permisos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Lista de roles
            Expanded(
              child: ListView.builder(
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(role['roleName']),
                      subtitle: Text('Permisos: ${role['permissions'].join(', ')}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editRole(index), // Editar rol
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Botón para agregar un nuevo rol
            Center(
              child: ElevatedButton(
                onPressed: _addRole, // Agregar nuevo rol
                child: const Text('Agregar Nuevo Rol'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
