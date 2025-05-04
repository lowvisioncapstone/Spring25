import 'package:flutter/material.dart';
import 'kitchen_scan_screen.dart';

class KitchenRecipeSelectPage extends StatelessWidget {
  const KitchenRecipeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Recipe'),
        backgroundColor: Color(0xFF99ccff),
      ),
      backgroundColor: Color(0xFFccddff),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please choose a recipe to begin:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KitchenScanScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: const Text('🥗 Salad'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
