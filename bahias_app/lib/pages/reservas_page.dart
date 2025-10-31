import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _ensureBaseData();
  }

  /// 🔧 Crea colecciones base si no existen
  Future<void> _ensureBaseData() async {
    final tipoEstado = _firestore.collection('Tipo_Estado');
    final estados = ['Libre', 'Ocupado', 'Mantenimiento', 'Reservado'];
    for (final e in estados) {
      final doc = await tipoEstado.doc(e).get();
      if (!doc.exists) {
        await tipoEstado.doc(e).set({'Descripcion': 'Estado $e creado automáticamente'});
      }
    }

    final estadoReserva = _firestore.collection('Estado_Reserva');
    final estadosReserva = ['Creada', 'En_uso', 'Finalizada', 'Cancelada'];
    for (final e in estadosReserva) {
      final doc = await estadoReserva.doc(e).get();
      if (!doc.exists) {
        await estadoReserva.doc(e).set({'Descripcion': 'Estado $e creado automáticamente'});
      }
    }
  }

  Color _estadoColor(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('ocup')) return Colors.amber;
    if (e.contains('manten')) return Colors.blueAccent;
    if (e.contains('reserv')) return Colors.purpleAccent;
    if (e.contains('cancel')) return Colors.redAccent;
    return Colors.greenAccent;
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
          if (snap.hasError) return const Center(child: Text('Error al cargar Reservas'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

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
              final estadoReservaRef = data['EstadoReservaRef'] as DocumentReference?;
              final bahiasRefs = (data['BahiasRefs'] as List?)?.cast<DocumentReference>() ?? [];
              final reprogramada = data['Reprogramada'] ?? false;

              return FutureBuilder(
                future: Future.wait([
                  usuario?.get() ?? _firestore.collection('Usuarios').doc('demoUser').get(),
                  estadoReservaRef?.get() ??
                      _firestore.collection('Estado_Reserva').doc('Creada').get(),
                  Future.wait(bahiasRefs.map((b) => b.get())),
                ]),
                builder: (context, snap2) {
                  if (!snap2.hasData) return const LinearProgressIndicator();

                  final usuarioDoc = snap2.data![0] as DocumentSnapshot<Map<String, dynamic>>;
                  final estadoReservaDoc = snap2.data![1] as DocumentSnapshot<Map<String, dynamic>>;
                  final bahiasDocs =
                      (snap2.data![2] as List).cast<DocumentSnapshot<Map<String, dynamic>>>();

                  final usuarioNombre = usuarioDoc.data()?['nombre'] ?? 'Sin usuario';
                  final estadoReserva = estadoReservaDoc.id;
                  final color = _estadoColor(estadoReserva);
                  final bahiasNombres = bahiasDocs.map((b) => b.id).join(', ');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Card(
                      color: const Color(0xFF111511),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: color.withOpacity(0.25),
                              child: Icon(Icons.event, color: color),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reserva $no',
                                      style: const TextStyle(
                                          color: Colors.lightBlueAccent,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("Usuario: $usuarioNombre",
                                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  Text("Bahías: $bahiasNombres",
                                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                  Text("Inicio: ${inicio.toString().substring(0, 16)}",
                                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                  Text("Fin: ${fin.toString().substring(0, 16)}",
                                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                  Text("Estado: $estadoReserva",
                                      style: TextStyle(color: color, fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_calendar,
                                      color: Colors.orangeAccent, size: 22),
                                  tooltip: 'Reprogramar',
                                  onPressed: reprogramada
                                      ? null
                                      : () => _reprogramarReserva(docs[i].id, inicio, fin),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.redAccent, size: 22),
                                  tooltip: 'Cancelar',
                                  onPressed: estadoReserva != 'Cancelada'
                                      ? () => _cancelarReserva(docs[i].id, bahiasRefs)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
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

  /// 🕓 Reprogramar reserva
  Future<void> _reprogramarReserva(String id, DateTime inicioAnt, DateTime finAnt) async {
    DateTime nuevoInicio = inicioAnt;
    DateTime nuevoFin = finAnt;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reprogramar Reserva", style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: const Color(0xFF111511),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
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
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: const Text("Cambiar Inicio",
                      style: TextStyle(color: Colors.greenAccent)),
                ),
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
                        final newFin = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        if (newFin.isBefore(nuevoInicio)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("La fecha de fin no puede ser menor a la de inicio"),
                            backgroundColor: Colors.redAccent,
                          ));
                          return;
                        }
                        setState(() => nuevoFin = newFin);
                      }
                    }
                  },
                  child: const Text("Cambiar Fin",
                      style: TextStyle(color: Colors.greenAccent)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.white70))),
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

  /// ❌ Cancelar reserva
  Future<void> _cancelarReserva(String id, List<DocumentReference> bahiasRefs) async {
    final libreRef = _firestore.collection('Tipo_Estado').doc('Libre');
    final canceladaRef = _firestore.collection('Estado_Reserva').doc('Cancelada');

    for (final ref in bahiasRefs) {
      await ref.update({'EstadoRef': libreRef});
    }

    await _firestore.collection('Reservas').doc(id).update({
      'EstadoReservaRef': canceladaRef,
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Reserva cancelada"),
      backgroundColor: Colors.redAccent,
    ));
  }

  /// 🧾 Crear reserva
  Future<void> _crearReserva(
      String usuarioId, Set<String> bahiasIds, DateTime inicio, DateTime fin) async {
    final coll = _firestore.collection('Reservas');
    final estadoRef = _firestore.collection('Estado_Reserva').doc('Creada');
    final usuarioRef = _firestore.collection('Usuarios').doc(usuarioId);
    final bahiasRefs = bahiasIds
        .map((id) => _firestore.collection('Bahias').doc(id))
        .toList();

    final last = await coll.orderBy('No_Reserva', descending: true).limit(1).get();
    final noReserva = last.docs.isEmpty ? 1 : (last.docs.first['No_Reserva'] ?? 0) + 1;

    await coll.add({
      'No_Reserva': noReserva,
      'UsuarioRef': usuarioRef,
      'BahiasRefs': bahiasRefs,
      'FechaInicio': Timestamp.fromDate(inicio),
      'FechaFin': Timestamp.fromDate(fin),
      'EstadoReservaRef': estadoRef,
      'Reprogramada': false,
      'FechaCreacion': Timestamp.now(),
    });

    final ocupadoRef = _firestore.collection('Tipo_Estado').doc('Ocupado');
    for (final ref in bahiasRefs) {
      await ref.update({'EstadoRef': ocupadoRef});
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Reserva creada correctamente"),
      backgroundColor: Colors.greenAccent,
    ));
  }

  /// 🧾 Formulario de creación
  Future<void> _mostrarFormularioReserva() async {
    final usuariosSnap = await _firestore.collection('Usuarios').get();
    final bahiasSnap = await _firestore.collection('Bahias').get();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No hay sesión activa."),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    final currentUserId = currentUser.uid;
    QueryDocumentSnapshot<Map<String, dynamic>>? currentUserDoc;
    final coincidencias = usuariosSnap.docs.where((d) => d.id == currentUserId).toList();

    if (coincidencias.isNotEmpty) {
      currentUserDoc = coincidencias.first;
    }

    final currentData = currentUserDoc?.data();
    String rol = 'cliente';
    final rolRef = currentData?['rolRef'];
    if (rolRef is DocumentReference) {
      rol = rolRef.id;
    }

    String? usuarioSel = rol == 'cliente' ? currentUserId : null;
    final seleccionadas = <String>{};
    DateTime? inicio;
    DateTime? fin;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Dialog(
          backgroundColor: const Color(0xFF111511),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Nueva Reserva",
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(height: 12),
                    if (rol != 'cliente')
                      DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF111511),
                        decoration: const InputDecoration(
                            labelText: "Usuario",
                            labelStyle: TextStyle(color: Colors.white70)),
                        items: usuariosSnap.docs
                            .map((u) => DropdownMenuItem(
                                  value: u.id,
                                  child: Text(
                                    (u.data())['nombre'] ?? 'Sin nombre',
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setModal(() => usuarioSel = v),
                      ),
                    const SizedBox(height: 16),
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
                            setModal(() {
                              inicio = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
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
                    TextButton(
                      onPressed: () async {
                        if (inicio == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Primero selecciona fecha de inicio")));
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
                            initialTime:
                                TimeOfDay.fromDateTime(inicio!),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "La fecha fin no puede ser menor que la de inicio")));
                              return;
                            }
                            setModal(() => fin = newFin);
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
                    const Text("Seleccionar Bahías",
                        style:
                            TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: bahiasSnap.docs.map((b) {
                        final libre =
                            (b['EstadoRef'] as DocumentReference?)?.id == 'Libre';
                        final selected = seleccionadas.contains(b.id);
                        return FilterChip(
                           label: Text(
                            "Bahía ${b['No_Bahia']}",
                            style: TextStyle(
                              color: libre
                                  ? (selected ? Colors.black : Colors.white)
                                  : Colors.white38,
                            ),
                          ),
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                          ),
                          onPressed: usuarioSel != null &&
                                  seleccionadas.isNotEmpty &&
                                  inicio != null &&
                                  fin != null
                              ? () async {
                                  await _crearReserva(
                                    usuarioSel!,
                                    seleccionadas,
                                    inicio!,
                                    fin!,
                                  );
                                  Navigator.pop(context);
                                }
                              : null,
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
        ),
      ),
    );
  }
}
