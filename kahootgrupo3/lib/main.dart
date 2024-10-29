import 'package:flutter/material.dart';
import 'preguntas.dart'; // Importa el archivo preguntas.dart

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MainPage(),
      routes: {
        '/preguntas': (context) => const PreguntasScreen(examenId: 'examen1'), // Define la ruta para PreguntasScreen
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navega a la pantalla de preguntas
            Navigator.pushNamed(context, '/preguntas');
          },
          child: const Text('Ir a Preguntas'),
        ),
      ),
    );
  }
}
