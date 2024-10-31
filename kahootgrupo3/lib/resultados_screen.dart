import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultadosScreen extends StatefulWidget {
  final String userId; // ID del usuario actual

  const ResultadosScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ResultadosScreenState createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> obtenerResultados() async {
    // Obtener los resultados de ambos usuarios
    final snapshot = await firestore.collection('resultados').get();
    final resultados = snapshot.docs.map((doc) => doc.data()).toList();

    if (resultados.length < 2) {
      return {'mensaje': 'Esperando más usuarios para comparar.'};
    }

    var usuario1 = resultados[0];
    var usuario2 = resultados[1];

    String ganador;
    if (usuario1['aciertos'] > usuario2['aciertos']) {
      ganador = 'Ganador: ${usuario1['userId']} con ${usuario1['aciertos']} aciertos.';
    } else if (usuario2['aciertos'] > usuario1['aciertos']) {
      ganador = 'Ganador: ${usuario2['userId']} con ${usuario2['aciertos']} aciertos.';
    } else {
      ganador = 'Es un empate con ${usuario1['aciertos']} aciertos.';
    }

    return {
      'usuario1': usuario1,
      'usuario2': usuario2,
      'ganador': ganador,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: obtenerResultados(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar resultados.'));
          }

          final data = snapshot.data!;
          if (data.containsKey('mensaje')) {
            return Center(child: Text(data['mensaje']));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuario 1: ${data['usuario1']['userId']} - ${data['usuario1']['aciertos']} aciertos'),
                Text('Usuario 2: ${data['usuario2']['userId']} - ${data['usuario2']['aciertos']} aciertos'),
                const SizedBox(height: 20),
                Text(
                  data['ganador'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
