import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Low Vision Daily Companion')),
        body: const ButtonScreen(),
      ),
    );
  }
}

class ButtonScreen extends StatelessWidget {
  const ButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(), // Pushes content to the bottom
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kitchen Assistant Pressed')),
                );
              },
              child: const Text('Kitchen Assistant'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu Assistant Pressed')),
                );
              },
              child: const Text('Menu Assistant'),
            ),
          ],
        ),
        const SizedBox(height: 40), // Adds space from bottom
      ],
    );
  }
}
