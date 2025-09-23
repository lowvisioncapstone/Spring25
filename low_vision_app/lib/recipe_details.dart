import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ingredients_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeUrl;

  const RecipeDetailScreen({super.key, required this.recipeUrl});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  String? _title;
  List<dynamic>? _ingredients;
  String? _instructions;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
  }
Future<void> _fetchRecipeDetails() async {
  final url = Uri.parse("http://128.180.121.231:5010/scrape"); 

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'url': widget.recipeUrl}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final title = data['title'];
      final ingredients = data['ingredients'];
      final instructions = data['instructions'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IngredientsScreen(
            title: title,
            ingredients: List<String>.from(ingredients),
            instructions: instructions,
          ),
        ),
      );
    } else {
      final errorData = json.decode(response.body);
      setState(() {
        _error = errorData['error'] ?? 'An error occurred.';
        _loading = false;
      });
    }
  } catch (e) {
    setState(() {
      _error = 'Failed to load recipe: $e';
      _loading = false;
    });
  }
}


 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Recipe Details'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Center(child: Text(_error ?? 'Unknown error')),
  );
}

}
