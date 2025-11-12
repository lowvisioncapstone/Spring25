import 'package:flutter/material.dart';
import 'kitchen_recipe_select.dart';

class KitchenInstructionPage extends StatelessWidget {
  const KitchenInstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Guide'),
        backgroundColor: Color(0xFF99ccff),
      ),
      backgroundColor: Color(0xFFccddff),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧂 How to use the Kitchen Assistant',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              '1. Prepare your kitchen area and make sure it is well-lit.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              '2. Tap the "Start" button to open the camera.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              '3. Point the camera at objects you want to recognize.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              '4. The app will detect and label kitchen items on screen.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text(
              '👉 Next, you will be asked to select a recipe to start.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KitchenRecipeSelectPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: const Text('Start'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
