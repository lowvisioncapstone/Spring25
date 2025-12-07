import 'package:flutter/material.dart';
import 'recipe_search.dart';

class KitchenRecipeSelectPage extends StatefulWidget {
  const KitchenRecipeSelectPage({super.key});

  @override
  State<KitchenRecipeSelectPage> createState() => _KitchenRecipeSelectPageState();
}

class _KitchenRecipeSelectPageState extends State<KitchenRecipeSelectPage> {
  final _form = GlobalKey<FormState>();
  final TextEditingController _recipeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _recipeController.dispose();
    super.dispose();
  }

  Future<void> _startRecipeScan() async {
    if (!_form.currentState!.validate()) return;

    final recipeName = _recipeController.text.trim();
    setState(() => _loading = true);
    try {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeSearchScreen(recipeName: recipeName),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reuse the same accessible colors and text styles
    const backgroundColor = Colors.black;
    const primaryTextColor = Colors.white;
    const accentTextColor = Color(0xFFFFA500); // orange
    const accentGreen = Color(0xFF00C853); // accessible green

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select a Recipe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: accentTextColor,
        foregroundColor: Colors.black,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                color: Colors.grey[900], // subtle contrast from background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: accentGreen, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '🍳 Choose Your Recipe',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: accentTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // const SizedBox(height: 20),
                        
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _recipeController,
                          style: const TextStyle(color: primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'Recipe name',
                            labelStyle: const TextStyle(color: accentTextColor),
                            hintText: 'e.g., Spaghetti Bolognese',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.restaurant_menu_outlined, color: accentGreen),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: accentGreen, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: accentTextColor, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Please enter a recipe name'
                                  : null,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _startRecipeScan(),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _loading ? null : _startRecipeScan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Start'),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: accentGreen),
                          label: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 22,
                              color: accentGreen,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: accentGreen, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
