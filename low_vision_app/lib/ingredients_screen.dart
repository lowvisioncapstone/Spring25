import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'dart:convert';

import 'steps_screen.dart';
import 'camera_ingredients.dart';

class IngredientsScreen extends StatefulWidget {
  final String title;
  final List<dynamic> ingredients;
  final String instructions;

  const IngredientsScreen({
    super.key,
    required this.title,
    required this.ingredients,
    required this.instructions,
  });

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {

  late Dio dio;
  final String baseUrl = 'http://128.180.121.231:5010'; 
  // or change to 8000 if the recipes API is running there.

  @override
  void initState() {
    super.initState();
    _setupDio();
  }

  Future<void> _setupDio() async {
    final dir = await getApplicationDocumentsDirectory();

    final cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/cookies'),
    );

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(CookieManager(cookieJar));
  }

  // ------------------ SAVE RECIPE (now with cookies + dio) ------------------

  Future<void> saveRecipe(BuildContext context) async {
    try {
      final response = await dio.post(
        '/recipes',
        data: {
          'title': widget.title,
          'ingredients': widget.ingredients,
          'instructions': [widget.instructions],
        },
        options: Options(
          validateStatus: (status) => true,
        ),
      );

      debugPrint("Save Recipe Status: ${response.statusCode}");
      debugPrint("Save Recipe Response: ${response.data}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${response.data}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Colors.black;
    const primaryTextColor = Colors.white;
    const accentTextColor = Color(0xFFFFA500);
    const accentGreen = Color(0xFF00C853);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
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
                  itemCount: widget.ingredients.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '• ${widget.ingredients[index]}',
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

            Center(
              child: Column(
                children: [
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
                                builder: (_) => CameraPage(
                                  ingredientList: widget.ingredients,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                                builder: (_) => StepsScreen(
                                  title: widget.title,
                                  instructions: widget.instructions,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
