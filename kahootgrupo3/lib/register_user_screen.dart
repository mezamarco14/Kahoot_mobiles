import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RegisterUserScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  String generateRandomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> registerUser(String name) async {
    String userId = generateRandomId();

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'username': name,
      'id': userId,
      'score': 0,
    });

    print('Usuario registrado: $name con ID: $userId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  await registerUser(name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Usuario registrado: $name')),
                  );
                  Navigator.pop(context); // Vuelve a la pantalla principal
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor ingresa un nombre.')),
                  );
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
