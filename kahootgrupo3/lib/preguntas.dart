import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore

class PreguntasScreen extends StatefulWidget {
  final String examenId; // Recibir el ID del examen

  const PreguntasScreen({Key? key, required this.examenId}) : super(key: key);

  @override
  _PreguntasScreenState createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends State<PreguntasScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Timer? _timer;
  int _counter = 10;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(VoidCallback onTimeout) {
    _counter = 10;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          timer.cancel();
          onTimeout();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas del Examen ${widget.examenId}'),
        backgroundColor: const Color(0xFF5C2D91), // Color morado estilo Kahoot
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escuchar los cambios en la colección 'preguntas'
        stream: firestore.collection('preguntas').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar preguntas.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final preguntas = snapshot.data?.docs;

          if (preguntas == null || preguntas.isEmpty) {
            return const Center(
              child: Text('No hay preguntas disponibles.'),
            );
          }

          return ListView.builder(
            itemCount: preguntas.length,
            itemBuilder: (context, index) {
              var pregunta = preguntas[index];

              return Card(
                color: const Color(0xFFF7E6A2), // Color crema estilo Kahoot
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        pregunta['enunciado'],
                        style: const TextStyle(color: Colors.black), // Texto en negro
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opciones: ${pregunta['opciones'].join(', ')}',
                            style: const TextStyle(color: Colors.black), // Texto en negro
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tiempo restante: $_counter segundos',
                            style: const TextStyle(color: Colors.black), // Texto en negro
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF5C2D91), // Color morado estilo Kahoot
                        onPrimary: Colors.white, // Texto en blanco
                      ),
                      onPressed: () {
                        // Lógica para marcar la respuesta
                        _timer?.cancel();
                      },
                      child: const Text('Responder'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startTimer(() {
      // Lógica para marcar la pregunta como errada y pasar a la siguiente
      setState(() {
        // Aquí se podría implementar la lógica para mover al siguiente ítem
        // Actualmente solo resetea el temporizador para la próxima pregunta
        _startTimer(() {});
      });
    });
  }
}
