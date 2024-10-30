import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'dart:async'; // Importar para usar Timer
import 'firebase_options.dart'; // Firebase options

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
      home: const PreguntasScreen(), // Llamar a la pantalla de PreguntasScreen
    );
  }
}

class PreguntasScreen extends StatefulWidget {
  const PreguntasScreen({Key? key}) : super(key: key);

  @override
  _PreguntasScreenState createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends State<PreguntasScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool isAnswered = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Has completado todas las preguntas.')),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas'),
        backgroundColor: Colors.blue, // Color de la barra de título
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Has completado todas las preguntas.')),
                              );
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
