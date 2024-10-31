import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'dart:async'; // Importar para usar Timer
import 'firebase_options.dart'; // Firebase options
import 'resultados_screen.dart'; // Importar la pantalla de resultados

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ocultar el banner de depuración
      title: 'Preguntas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PreguntasScreen(userId: 'someUserId', username: 'someUsername'), // Llamar a la pantalla de PreguntasScreen
    );
  }
}

class PreguntasScreen extends StatefulWidget {
  final String userId; // Recibir el ID del usuario desde otra pantalla
  final String username; // Recibir el nombre de usuario

  const PreguntasScreen({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  _PreguntasScreenState createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends State<PreguntasScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool isAnswered = false;
  Timer? timer;
  int aciertos = 0; // Aciertos del usuario

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer(List<QueryDocumentSnapshot> preguntas) {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 6), () {
      if (!isAnswered) {
        setState(() {
          if (currentQuestionIndex < preguntas.length - 1) {
            currentQuestionIndex++;
            selectedOption = null;
            isAnswered = false;
          } else {
            guardarResultados(); // Guardar los resultados en Firebase
          }
        });
      }
    });
  }

  Future<void> guardarResultados() async {
    await firestore.collection('resultados').doc(widget.userId).set({
      'userId': widget.userId,
      'aciertos': aciertos,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultadosScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas - Usuario: ${widget.username}'), // Mostrar nombre de usuario
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('preguntas').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
              startTimer(snapshot.data!.docs);

              var pregunta = preguntas[currentQuestionIndex];
              var opciones = List<String>.from(pregunta['opciones']);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pregunta['enunciado'],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ...opciones.map((opcion) => RadioListTile<String>(
                          title: Text(opcion),
                          value: opcion,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value;
                            });
                          },
                        )),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isAnswered || selectedOption == null
                          ? null
                          : () {
                              setState(() {
                                isAnswered = true;
                                timer?.cancel();
                                if (selectedOption == pregunta['respuesta']) {
                                  aciertos++; // Incrementar aciertos
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Respuesta correcta!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Respuesta incorrecta.')),
                                  );
                                }
                              });
                            },
                      child: const Text('Validar'),
                    ),
                    const SizedBox(height: 20),
                    if (isAnswered)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (currentQuestionIndex < preguntas.length - 1) {
                              currentQuestionIndex++;
                              selectedOption = null;
                              isAnswered = false;
                              startTimer(snapshot.data!.docs);
                            } else {
                              guardarResultados(); // Guardar resultados y navegar
                            }
                          });
                        },
                        child: const Text('Siguiente pregunta'),
                      ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'images/images.webp',
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
