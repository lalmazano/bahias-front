import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _ensureBaseData();
    _ensureDefaultReservas();
  }

  /// 🧩 Crea colecciones base y corrige datos incompletos
  Future<void> _ensureBaseData() async {
    // Tipo_Estado
    final tipoEstado = _firestore.collection('Tipo_Estado');
    final estados = ['Libre', 'Ocupado', 'Mantenimiento', 'Reservado'];
    for (final e in estados) {
      final doc = await tipoEstado.doc(e).get();
      if (!doc.exists) {
        await tipoEstado.doc(e).set({'Descripcion': 'Estado $e creado automáticamente'});
      }
    }

    // Tipo_Bahia
    final tipoBahia = _firestore.collection('Tipo_Bahia');
    final tipos = ['General', 'Ligera', 'Pesada', 'Refrigerado'];
    for (final t in tipos) {
      final doc = await tipoBahia.doc(t).get();
      if (!doc.exists) {
        await tipoBahia.doc(t).set({'Descripcion': 'Bahía tipo $t'});
      }
    }

    // Estado_Reserva
    final estadoReserva = _firestore.collection('Estado_Reserva');
    final estadosReserva = ['Creada', 'En_uso', 'Finalizada', 'Cancelada'];
    for (final e in estadosReserva) {
      final doc = await estadoReserva.doc(e).get();
      if (!doc.exists) {
        await doc.reference.set({'Descripcion': 'Estado de reserva $e creado automáticamente'});
      }
    }

    // Usuarios
    final usuarios = _firestore.collection('Usuarios');
    final usuariosSnap = await usuarios.get();
    if (usuariosSnap.docs.isEmpty) {
      await usuarios.doc('demoUser').set({'nombre': 'Usuario de Prueba', 'rolRef': '/Roles/anonimo'});
    } else {
      for (final doc in usuariosSnap.docs) {
        final data = doc.data();
        if (!data.containsKey('nombre')) {
          await doc.reference.update({'nombre': 'Usuario sin nombre'});
        } 
      }
    }
  }

  /// 🧠 Corrige campos faltantes en Reservas
  Future<void> _ensureDefaultReservas() async {
    final reservas = await _firestore.collection('Reservas').get();
    final estadoRefDefault = _firestore.collection('Tipo_Estado').doc('Reservado');
    final estadoReservaDefault = _firestore.collection('Estado_Reserva').doc('Creada');
    final usuarioRefDefault = _firestore.collection('Usuarios').doc('demoUser');

    for (final doc in reservas.docs) {
      final data = doc.data();
      final updates = <String, dynamic>{};

      if (!data.containsKey('No_Reserva')) {
        final num = int.tryParse(doc.id) ?? 0;
        updates['No_Reserva'] = num;
      }
      if (!data.containsKey('UsuarioRef') || data['UsuarioRef'] == null) {
        updates['UsuarioRef'] = usuarioRefDefault;
      }
      if (!data.containsKey('BahiasRefs') || data['BahiasRefs'] == null) {
        updates['BahiasRefs'] = [];
      }
      if (!data.containsKey('FechaInicio') || data['FechaInicio'] == null) {
        updates['FechaInicio'] = Timestamp.fromDate(DateTime.now());
      }
      if (!data.containsKey('FechaFin') || data['FechaFin'] == null) {
        updates['FechaFin'] = Timestamp.fromDate(DateTime.now().add(const Duration(hours: 2)));
      }
      if (!data.containsKey('EstadoRef') || data['EstadoRef'] == null) {
        updates['EstadoRef'] = estadoRefDefault;
      }
      if (!data.containsKey('EstadoReservaRef') || data['EstadoReservaRef'] == null) {
        updates['EstadoReservaRef'] = estadoReservaDefault;
      }
      if (!data.containsKey('Reprogramada')) {
        updates['Reprogramada'] = false;
      }

      if (updates.isNotEmpty) {
        await doc.reference.update(updates);
      }
    }
  }

  Color _estadoColor(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('ocup')) return const Color(0xFFFFC107);
    if (e.contains('manten')) return const Color(0xFF42A5F5);
    if (e.contains('reserv')) return const Color(0xFF9C27B0);
    return const Color(0xFF2ECC71);
  }

  @override
  Widget build(BuildContext context) {
    final ref = _firestore.collection('Reservas').orderBy('No_Reserva').snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0B),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Reservas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.greenAccent),
            tooltip: 'Nueva reserva',
            onPressed: _mostrarFormularioReserva,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ref,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Error al cargar Reservas'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay reservas registradas',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final no = data['No_Reserva'] ?? 0;
              final usuario = data['UsuarioRef'] as DocumentReference?;
              final inicio = (data['FechaInicio'] as Timestamp).toDate();
              final fin = (data['FechaFin'] as Timestamp).toDate();
              final bahiasRefs = (data['BahiasRefs'] as List?)?.cast<DocumentReference>() ?? [];
              final estadoRef = data['EstadoRef'] as DocumentReference?;
              final estadoReservaRef = data['EstadoReservaRef'] as DocumentReference?;
              final reprogramada = data['Reprogramada'] ?? false;

              return FutureBuilder(
                future: Future.wait([
                  usuario?.get() ?? _firestore.collection('Usuarios').doc('demoUser').get(),
                  estadoRef?.get() ?? _firestore.collection('Tipo_Estado').doc('Reservado').get(),
                  estadoReservaRef?.get() ??
                      _firestore.collection('Estado_Reserva').doc('Creada').get(),
                  Future.wait(bahiasRefs.map((b) => b.get())),
                ]),
                builder: (context, snap2) {
                  if (!snap2.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final usuarioDoc = snap2.data![0] as DocumentSnapshot<Map<String, dynamic>>;
                  final estadoDoc = snap2.data![1] as DocumentSnapshot<Map<String, dynamic>>;
                  final estadoReservaDoc =
                      snap2.data![2] as DocumentSnapshot<Map<String, dynamic>>;
                  final bahiasDocs =
                      (snap2.data![3] as List).cast<DocumentSnapshot<Map<String, dynamic>>>();

                  final usuarioNombre = usuarioDoc.data()?['nombre'] ?? 'Sin usuario';
                  final estadoNombre = estadoDoc.id;
                  final estadoReservaNombre = estadoReservaDoc.id;
                  final bahiasNombres = bahiasDocs.map((b) => b.id).join(', ');
                  final color = _estadoColor(estadoNombre);

                  return Card(
                    color: const Color(0xFF111511),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.25),
                        child: Icon(Icons.event, color: color),
                      ),
                      title: Text('Reserva $no',
                          style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Usuario: $usuarioNombre",
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          Text("Bahías: $bahiasNombres",
                              style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          Text("Inicio: ${inicio.toString().substring(0, 16)}",
                              style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          Text("Fin: ${fin.toString().substring(0, 16)}",
                              style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          Text("Estado reserva: $estadoReservaNombre",
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                        ],
                      ),
                      trailing: Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_calendar, color: Colors.orangeAccent),
                            tooltip: 'Reprogramar fecha/hora',
                            onPressed:
                                reprogramada ? null : () => _reprogramarReserva(docs[i].id, inicio, fin),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _eliminarReserva(docs[i].id, bahiasRefs),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// 🕒 Reprogramar fecha/hora una sola vez (sin redundancias)
  Future<void> _reprogramarReserva(String id, DateTime inicioAnt, DateTime finAnt) async {
    DateTime nuevoInicio = inicioAnt;
    DateTime nuevoFin = finAnt;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Text("Reprogramar Reserva", style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: const Color(0xFF111511),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: inicioAnt,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(inicioAnt),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          nuevoInicio = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute);
                        });
                      }
                    }
                  },
                  child: const Text("Cambiar Inicio",
                      style: TextStyle(color: Colors.greenAccent))),
              TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: finAnt,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(finAnt),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          nuevoFin = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute);
                        });
                      }
                    }
                  },
                  child: const Text("Cambiar Fin",
                      style: TextStyle(color: Colors.greenAccent))),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () async {
              await _firestore.collection('Reservas').doc(id).update({
                'FechaInicioAnterior': Timestamp.fromDate(inicioAnt),
                'FechaFinAnterior': Timestamp.fromDate(finAnt),
                'FechaInicio': Timestamp.fromDate(nuevoInicio),
                'FechaFin': Timestamp.fromDate(nuevoFin),
                'Reprogramada': true,
                'FechaReprogramacion': Timestamp.now(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Reserva reprogramada correctamente"),
                backgroundColor: Colors.orangeAccent,
              ));
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// 🧾 Formulario de creación
  Future<void> _mostrarFormularioReserva() async {
    final usuariosSnap = await _firestore.collection('Usuarios').get();
    final bahiasSnap = await _firestore.collection('Bahias').get();

    String? usuarioSel;
    final seleccionadas = <String>{};
    DateTime inicio = DateTime.now();
    DateTime fin = DateTime.now().add(const Duration(hours: 2));

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => AlertDialog(
          backgroundColor: const Color(0xFF111511),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Nueva Reserva",
              style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF111511),
                  decoration: const InputDecoration(
                      labelText: "Usuario", labelStyle: TextStyle(color: Colors.white70)),
                  items: usuariosSnap.docs
                      .map((u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(
                              (u.data() as Map<String, dynamic>?)?['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setModal(() => usuarioSel = v),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar Bahías",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                Wrap(
                  spacing: 6,
                  children: bahiasSnap.docs.map((b) {
                    final libre = (b['EstadoRef'] as DocumentReference?)?.id == 'Libre';
                    final selected = seleccionadas.contains(b.id);
                    return FilterChip(
                      label: Text("Bahía ${b['No_Bahia']}",
                          style: TextStyle(
                              color: libre
                                  ? (selected ? Colors.black : Colors.white)
                                  : Colors.white38)),
                      selected: selected,
                      backgroundColor: Colors.grey.shade800,
                      selectedColor: Colors.greenAccent,
                      onSelected: libre
                          ? (val) {
                              setModal(() {
                                val
                                    ? seleccionadas.add(b.id)
                                    : seleccionadas.remove(b.id);
                              });
                            }
                          : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: inicio,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(inicio),
                            );
                            if (pickedTime != null) {
                              setModal(() {
                                inicio = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute);
                              });
                            }
                          }
                        },
                        child: const Text("Inicio",
                            style: TextStyle(color: Colors.greenAccent))),
                    TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: fin,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(fin),
                            );
                            if (pickedTime != null) {
                              setModal(() {
                                fin = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute);
                              });
                            }
                          }
                        },
                        child: const Text("Fin",
                            style: TextStyle(color: Colors.greenAccent))),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancelar", style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              onPressed: usuarioSel != null && seleccionadas.isNotEmpty
                  ? () async {
                      await _crearReserva(usuarioSel!, seleccionadas, inicio, fin);
                      Navigator.pop(context);
                    }
                  : null,
              child:
                  const Text("Guardar", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧠 Crear reserva y actualizar estados
  Future<void> _crearReserva(
      String usuarioId, Set<String> bahiasIds, DateTime inicio, DateTime fin) async {
    final coll = _firestore.collection('Reservas');
    final total = (await coll.get()).size;
    final noReserva = total + 1;

    final estadoRef = _firestore.collection('Tipo_Estado').doc('Reservado');
    final estadoReservaRef = _firestore.collection('Estado_Reserva').doc('Creada');
    final usuarioRef = _firestore.collection('Usuarios').doc(usuarioId);
    final bahiasRefs =
        bahiasIds.map((id) => _firestore.collection('Bahias').doc(id)).toList();

    await coll.doc(noReserva.toString().padLeft(3, '0')).set({
      'No_Reserva': noReserva,
      'UsuarioRef': usuarioRef,
      'BahiasRefs': bahiasRefs,
      'FechaInicio': Timestamp.fromDate(inicio),
      'FechaFin': Timestamp.fromDate(fin),
      'EstadoRef': estadoRef,
      'EstadoReservaRef': estadoReservaRef,
      'Reprogramada': false,
    });

    for (final ref in bahiasRefs) {
      await ref.update({'EstadoRef': estadoRef});
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Reserva creada correctamente"),
      backgroundColor: Colors.green,
    ));
  }

  /// 🗑️ Eliminar reserva y liberar bahías
  Future<void> _eliminarReserva(String id, List<DocumentReference> bahiasRefs) async {
    final libreRef = _firestore.collection('Tipo_Estado').doc('Libre');
    for (final ref in bahiasRefs) {
      await ref.update({'EstadoRef': libreRef});
    }

    await _firestore.collection('Reservas').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Reserva eliminada"),
      backgroundColor: Colors.redAccent,
    ));
  }
}
