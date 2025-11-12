import 'package:flutter/material.dart';
import 'steps_screen.dart';
import 'camera_ingredients.dart';
import 'tts_service.dart';
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
    // Accessibility colors and style constants
    const backgroundColor = Colors.black;
    const primaryTextColor = Colors.white;
    const accentTextColor = Color(0xFFFFA500); // Orange
    const accentGreen = Color(0xFF00C853); // Accessible green

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: accentTextColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accentTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentGreen, width: 1.5),
                ),
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '• ${ingredients[index]}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: primaryTextColor,
                          height: 1.4,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Buttons section
            Center(
              child: Column(
                children: [
                  // Row 1: Open Camera + View Steps
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text(
                            'Open Camera',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CameraPage(ingredientList: ingredients),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            textStyle: const TextStyle(fontSize: 16),
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.list_alt, size: 16),
                          label: const Text(
                            'View Steps',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            textStyle: const TextStyle(fontSize: 16),
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Row 2: Save Recipe + Back
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: accentGreen, size: 16),
                          label: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: accentGreen,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: accentGreen, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.bookmark_add, size: 16),
                          label: const Text(
                            'Save Recipe',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => saveRecipe(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            textStyle: const TextStyle(fontSize: 16),
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
