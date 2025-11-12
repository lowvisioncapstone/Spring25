import 'package:flutter/material.dart';
import 'recipe_search.dart';

class KitchenRecipeSelectPage extends StatefulWidget {
  const KitchenRecipeSelectPage({super.key});

  @override
  State<KitchenRecipeSelectPage> createState() => _KitchenRecipeSelectPageState();
}

class _KitchenRecipeSelectPageState extends State<KitchenRecipeSelectPage> {
  final TextEditingController _recipeController = TextEditingController();

  @override
  void dispose() {
    _recipeController.dispose();
    super.dispose();
  }

  void _startRecipeScan() {
    final recipeName = _recipeController.text.trim();
    if (recipeName.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeSearchScreen(recipeName: recipeName),
        ),
      );
    } else {
      // Optionally show a snackbar or alert if the field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe name')),
      );
    }
  }

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
              'Please type the name of a recipe to begin:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _recipeController,
              decoration: InputDecoration(
                hintText: 'e.g., Spaghetti Bolognese',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _startRecipeScan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: const Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
