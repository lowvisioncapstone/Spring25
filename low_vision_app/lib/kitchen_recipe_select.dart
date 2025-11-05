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
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Select a Recipe',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please type the name of a recipe to begin:',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _recipeController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe name',
                        hintText: 'e.g., Spaghetti Bolognese',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant_menu_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter a recipe name'
                          : null,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _startRecipeScan(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loading ? null : _startRecipeScan,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Start'),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
