import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/services.dart';

class FormularioReserva extends StatefulWidget {
  final ReservaService service;
  final bool puedeAsignarUsuario; // ← se recibe desde ReservasPage

  const FormularioReserva({
    super.key,
    required this.service,
    this.puedeAsignarUsuario = false,
  });

  @override
  State<FormularioReserva> createState() => _FormularioReservaState();
}

class _FormularioReservaState extends State<FormularioReserva> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final Set<String> seleccionadas = {};
  DateTime? inicio;
  DateTime? fin;
  String? usuarioSel;

  bool cargandoBahias = false;
  bool cargandoUsuarios = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> bahiasDisponibles = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> usuarios = [];

  /// 🔍 Obtiene bahías disponibles según rango de fechas
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _obtenerBahiasDisponibles(
      DateTime inicio, DateTime fin) async {
    final reservasActivas = await _firestore
        .collection('Reservas')
        .where('EstadoReservaRef', whereIn: [
          _firestore.collection('Estado_Reserva').doc('Creada'),
          _firestore.collection('Estado_Reserva').doc('En_uso'),
          _firestore.collection('Estado_Reserva').doc('Reservado')
        ])
        .get();

    final bahiasOcupadas = <String>{};
    for (final res in reservasActivas.docs) {
      final data = res.data();
      final inicioExistente = (data['FechaInicio'] as Timestamp).toDate();
      final finExistente = (data['FechaFin'] as Timestamp).toDate();
      final bahiasRefs =
          (data['BahiasRefs'] as List?)?.cast<DocumentReference>() ?? [];

      final seSolapan =
          (inicio.isBefore(finExistente) && fin.isAfter(inicioExistente));

      if (seSolapan) {
        for (final ref in bahiasRefs) {
          bahiasOcupadas.add(ref.id);
        }
      }
    }

    final todasBahias = await _firestore.collection('Bahias').get();
    return todasBahias.docs
        .where((b) => !bahiasOcupadas.contains(b.id))
        .toList();
  }

  /// 🔧 Carga inicial del usuario actual y lista si tiene permiso
  Future<void> _initUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    usuarioSel = currentUser.uid; // por defecto su propio usuario

    if (widget.puedeAsignarUsuario) {
      setState(() => cargandoUsuarios = true);
      final usuariosSnap = await _firestore.collection('Usuarios').get();
      usuarios = usuariosSnap.docs;
      setState(() => cargandoUsuarios = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  /// 🔥 Crea la reserva
  Future<void> _guardarReserva() async {
    if (usuarioSel == null || inicio == null || fin == null || seleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Completa todos los campos antes de continuar."),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    await widget.service.crearReserva(
      usuarioSel!,
      seleccionadas,
      inicio!,
      fin!,
      context,
    );

    if (mounted) Navigator.pop(context);
  }

  /// 🔄 Actualiza la lista de bahías según fechas seleccionadas
  Future<void> _actualizarBahiasDisponibles() async {
    if (inicio == null || fin == null) return;
    setState(() => cargandoBahias = true);
    bahiasDisponibles = await _obtenerBahiasDisponibles(inicio!, fin!);
    setState(() => cargandoBahias = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111511),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Nueva Reserva",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),

                // 🧑‍💻 Selección de usuario (solo admin u operador)
                if (widget.puedeAsignarUsuario)
                  cargandoUsuarios
                      ? const CircularProgressIndicator(color: Colors.greenAccent)
                      : DropdownButtonFormField<String>(
                          value: usuarioSel,
                          dropdownColor: const Color(0xFF222222),
                          decoration: const InputDecoration(
                            labelText: "Asignar a usuario",
                            labelStyle: TextStyle(color: Colors.white70),
                          ),
                          items: usuarios.map((u) {
                            return DropdownMenuItem<String>(
                              value: u.id,
                              child: Text(
                                u['nombre'] ?? u['correo'] ?? 'Sin nombre',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => usuarioSel = val),
                        )
                else
                  Text(
                    "Usuario: ${_auth.currentUser?.email ?? 'Desconocido'}",
                    style: const TextStyle(color: Colors.white70),
                  ),

                const SizedBox(height: 20),

                // 📅 Fecha/hora inicio
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          inicio = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                        await _actualizarBahiasDisponibles();
                      }
                    }
                  },
                  child: Text(
                    inicio == null
                        ? "Seleccionar fecha/hora inicio"
                        : "Inicio: ${inicio.toString().substring(0, 16)}",
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                ),

                // 📅 Fecha/hora fin
                TextButton(
                  onPressed: () async {
                    if (inicio == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Primero selecciona la fecha de inicio."),
                      ));
                      return;
                    }
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: inicio!,
                      firstDate: inicio!,
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(inicio!),
                      );
                      if (pickedTime != null) {
                        final newFin = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        if (newFin.isBefore(inicio!)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("La fecha de fin no puede ser menor a la de inicio."),
                          ));
                          return;
                        }
                        setState(() => fin = newFin);
                        await _actualizarBahiasDisponibles();
                      }
                    }
                  },
                  child: Text(
                    fin == null
                        ? "Seleccionar fecha/hora fin"
                        : "Fin: ${fin.toString().substring(0, 16)}",
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  "Seleccionar Bahías disponibles",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),

                if (cargandoBahias)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  )
                else if (inicio == null || fin == null)
                  const Text(
                    "Selecciona fecha y hora para ver bahías.",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  )
                else if (bahiasDisponibles.isEmpty)
                  const Text(
                    "No hay bahías disponibles en este rango.",
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: bahiasDisponibles.map((b) {
                      final selected = seleccionadas.contains(b.id);
                      return FilterChip(
                        label: Text(
                          "Bahía ${b['No_Bahia']}",
                          style: TextStyle(
                            color: selected ? Colors.black : Colors.white,
                          ),
                        ),
                        selected: selected,
                        backgroundColor: Colors.grey.shade800,
                        selectedColor: Colors.greenAccent,
                        onSelected: (val) {
                          setState(() {
                            val ? seleccionadas.add(b.id) : seleccionadas.remove(b.id);
                          });
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar",
                          style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                      ),
                      onPressed: _guardarReserva,
                      child: const Text(
                        "Guardar",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
