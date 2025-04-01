import 'package:flutter/material.dart';

class KitchenScanScreen extends StatelessWidget {
  const KitchenScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Assistant')),
      body: const Center(
        child: Text('This is the Kitchen Assistant screen.'),
      ),
    );
  }
}
