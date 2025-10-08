import 'package:flutter/material.dart';
import 'steps_screen.dart'; 
import 'camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class IngredientsScreen extends StatelessWidget {
  final String title;
  final List<dynamic> ingredients;
  final String instructions;

  const IngredientsScreen({
    super.key,
    required this.title,
    required this.ingredients,
    required this.instructions,
  });

  Future<void> saveRecipe(BuildContext context) async {
    const String backendUrl = 'http://128.180.121.231:5010/save_recipe'; 

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'ingredients': ingredients,
          'instructions': instructions,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${response.body}')),
        );
      }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return Text('• ${ingredients[index]}');
                },
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Open Camera'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CameraPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  const SizedBox(height: 10),
              
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StepsScreen(
                            title: title,
                            instructions: instructions,
                          ),
                        ),
                      );
                    },
                    child: const Text('View Steps'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bookmark_add),
                    label: const Text('Save Recipe'),
                    onPressed: () => saveRecipe(context),
                  ),
                ],
              )

                ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}
