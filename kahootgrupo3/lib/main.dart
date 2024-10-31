import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'register_user_screen.dart';
import 'preguntas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const MainPage(), // Página principal del juego
      routes: {
        '/register': (context) =>  RegisterUserScreen(), // Ruta del registro
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/preguntas') {
          final args = settings.arguments as Map<String, String>; // Recibe argumentos
          return MaterialPageRoute(
            builder: (context) => PreguntasScreen(
              userId: args['userId']!,
              username: args['username']!,
            ),
          );
        }
        return null;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register'); // Navega a registro
              },
              child: const Text('Registrar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
