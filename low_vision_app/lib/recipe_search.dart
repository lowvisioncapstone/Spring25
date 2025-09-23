import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart';
import 'dart:convert';
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

  Future<void> _searchGoogle(String query) async{
    final url = 'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$searchEngineID&q=$query&start=$_startIndex';

    try{
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (response.statusCode == 200){
        final items = data['items'] as List<dynamic>?; 

        if (items != null && items.isNotEmpty){
          setState((){
            _results = items.take(5).toList();
            _startIndex +=5;
            _hasMore = items.length == 10; //check if there are 10 more
            _loading = false;
          });
        } else{
          setState(() {
            _hasMore = false;
            _loading = false;
          });
        }
      } 
    }catch (e) {
        setState((){
          _error = 'Error occurred:  $e';
          _loading = false;
        });
      }
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Searching: ${widget.recipeName} recipe'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(item['title'] ?? 'No Title'),
                              subtitle: Text(item['snippet'] ?? 'No snippet'),
                              onTap: () {
                                final recipeUrl = item['link'];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(recipeUrl: recipeUrl),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (_hasMore && !_loading)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                          });
                          _searchGoogle(widget.recipeName);
                        },
                        child: const Text("View more recipes"),
                      ),
                    if (_loading) const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
    ),
  );
}
}