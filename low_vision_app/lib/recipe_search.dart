import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recipe_details.dart';

class RecipeSearchScreen extends StatefulWidget {
  final String recipeName;
  const RecipeSearchScreen({super.key, required this.recipeName});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  List<dynamic> _results = [];
  bool _loading = true;
  String? _error;
  int _startIndex = 1;
  bool _hasMore = true;

  final String apiKey = "AIzaSyAaaIAs9L1rgKSgUKmH1tzggZGNGttiDFo";
  final String searchEngineID = "70557612f36394ad1";

  @override
  void initState() {
    super.initState();
    _searchGoogle(widget.recipeName);
  }

  Future<void> _searchGoogle(String query, {bool isNext = true}) async {
    int newStartIndex = isNext ? _startIndex + 5 : _startIndex - 5;
    if (newStartIndex < 1) return;

    final url =
        'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$searchEngineID&q=$query&start=$newStartIndex';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final items = data['items'] as List<dynamic>?;

        setState(() {
          _results = items?.take(5).toList() ?? [];
          _startIndex = newStartIndex;
          _hasMore = items != null && items.length >= 5;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Failed to load results.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error occurred: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Shared accessible colors
    const backgroundColor = Colors.black;
    const primaryTextColor = Colors.white;
    const accentTextColor = Color(0xFFFFA500); // orange
    const accentGreen = Color(0xFF00C853); // green

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Searching: ${widget.recipeName} Recipe',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: accentTextColor,
        foregroundColor: Colors.black,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: accentGreen,
                ),
              )
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            return Card(
                              color: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: accentGreen, width: 1.5),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                title: Text(
                                  item['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    color: accentTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  item['snippet'] ?? 'No description available.',
                                  style: const TextStyle(
                                    color: primaryTextColor,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                onTap: () {
                                  final recipeUrl = item['link'];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailScreen(
                                          recipeUrl: recipeUrl),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Pagination buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_startIndex > 6)
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _loading = true);
                                _searchGoogle(widget.recipeName,
                                    isNext: false);
                              },
                              icon: const Icon(Icons.arrow_back,
                                  color: accentGreen, size: 16),
                              label: const Text(
                                'Previous',
                                style: TextStyle(
                                  color: accentGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: accentGreen, width: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          if (_startIndex > 6 && _hasMore)
                            const SizedBox(width: 16),
                          if (_hasMore)
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _loading = true);
                                _searchGoogle(widget.recipeName, isNext: true);
                              },
                              icon: const Icon(Icons.arrow_forward,
                                  color: accentGreen, size: 16),
                              label: const Text(
                                'Next',
                                style: TextStyle(
                                  color: accentGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: accentGreen, width: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
