import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'ingredients_screen.dart';

class SavedRecipesPage extends StatefulWidget {
  const SavedRecipesPage({super.key});

  @override
  State<SavedRecipesPage> createState() => _SavedRecipesPageState();
}

class _SavedRecipesPageState extends State<SavedRecipesPage> {
  List<Map<String, dynamic>> _recipes = [];
  bool _loading = true;
  late Dio dio;

  final Color backgroundColor = Colors.black;
  final Color primaryTextColor = Colors.white;
  final Color accentTextColor = Color(0xFFFFA500);
  final Color accentGreen = Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    _setupDio().then((_) => fetchRecipes());
  }

  Future<void> _setupDio() async {
    final dir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/cookies'),
    );

    dio = Dio(BaseOptions(
      baseUrl: 'http://128.180.121.231:5010',
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await dio.get('/recipes');

      if (response.statusCode == 200) {
        setState(() {
          _recipes = List<Map<String, dynamic>>.from(response.data['recipes']);
          _loading = false;
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Saved Recipes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: accentTextColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _recipes.isEmpty
                ? Center(
                    child: Text(
                      'No saved recipes.',
                      style: TextStyle(fontSize: 20, color: primaryTextColor),
                    ),
                  )
                : ListView.builder(
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return Card(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: accentGreen, width: 1.5),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            recipe['name'],
                            style: TextStyle(
                                color: primaryTextColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onTap: () {
                            final ingredients = List<String>.from(recipe['ingredients']);
                            final instructions = (recipe['steps'] as List<dynamic>).join('\n');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IngredientsScreen(
                                  title: recipe['name'],
                                  ingredients: ingredients,
                                  instructions: instructions,
                                ),
                              ),
                            );
                          },

                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    final ingredients = List<String>.from(recipe['ingredients']);
    final steps = List<String>.from(recipe['steps']);

    const Color backgroundColor = Colors.black;
    const Color primaryTextColor = Colors.white;
    const Color accentTextColor = Color(0xFFFFA500);
    const Color accentGreen = Color(0xFF00C853);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          recipe['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: accentTextColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accentTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentGreen, width: 1.5),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ingredients
                    .map((ing) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '• $ing',
                            style: const TextStyle(
                              fontSize: 20,
                              color: primaryTextColor,
                              height: 1.4,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Steps',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accentTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentGreen, width: 1.5),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '${entry.key + 1}. ${entry.value}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: primaryTextColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
