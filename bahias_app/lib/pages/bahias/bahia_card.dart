import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class BahiaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool selected;
  final bool showLock;
  final VoidCallback onLongPress;
  final BahiasService service;

  const BahiaCard({
    super.key,
    required this.data,
    required this.selected,
    required this.showLock,
    required this.onLongPress,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final no = data['No_Bahia'] ?? 0;
    final estadoRef = data['EstadoRef'] as DocumentReference?;
    final tipoRef = data['TipoRef'] as DocumentReference?;
    final ubicacionRef = data['UbicacionRef'] as DocumentReference?;
    final estado = estadoRef?.id ?? 'Desconocido';
    final tipo = tipoRef?.id ?? 'Sin tipo';
    final estadoColor = service.estadoColor(estado);

    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.12)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.9)
                : theme.dividerColor.withOpacity(0.25),
            width: 1.3,
          ),
          boxShadow: [
            // 🌗 Sombra adaptativa según tema
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? Colors.black.withOpacity(0.05)
                  : Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            if (selected)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.25),
                blurRadius: 12,
                spreadRadius: 1.5,
              ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bahía $no',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary, // azul institucional
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: estadoColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tipo: $tipo",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
                FutureBuilder<DocumentSnapshot>(
                  future: ubicacionRef?.get(),
                  builder: (context, snapshot) {
                    String nombreUbicacion = 'Sin ubicación';

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      nombreUbicacion = data?['Nombre'] ?? 'Sin nombre';
                    }

                    return Text(
                      "Ubicación: $nombreUbicacion",
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 13,
                      ),
                    );
                  },
                ),
                if (showLock)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
