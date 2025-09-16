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
<<<<<<< HEAD
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
=======
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
>>>>>>> 362c100e128e4b75e3cc5bd92cd4ea2ab7eec3df
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
