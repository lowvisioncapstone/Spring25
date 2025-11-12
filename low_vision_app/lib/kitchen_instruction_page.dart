import 'package:flutter/material.dart';
import 'kitchen_recipe_select.dart';
import 'saved_recipes_page.dart';

class KitchenInstructionPage extends StatelessWidget {
  const KitchenInstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define accessible colors
    const backgroundColor = Colors.black; // dark background
    const primaryTextColor = Colors.white; // high contrast on black
    const accentTextColor = Color(0xFFFFA500); // orange accent (#FFA500)
    const accentGreen = Color(0xFF00C853); // accessible green (#00C853)

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kitchen Guide',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: accentTextColor,
        foregroundColor: Colors.black,
      ),
      backgroundColor: backgroundColor,

      // ✅ Make the whole body scrollable
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '🧂 How to use the Kitchen Assistant',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: accentTextColor, // orange title
                ),
              ),
              const SizedBox(height: 20),

              // Steps
              const _InstructionStep(
                number: '1.',
                text:
                    'Say (for now, type) the name of the recipe you want to cook.',
              ),
              const _InstructionStep(
                number: '2.',
                text:
                    'Listen to the provided options and select the recipe you would like to prepare, or select "more" to hear more options.',
              ),
              const _InstructionStep(
                number: '3.',
                text:
                    'Prepare your kitchen area and make sure it is well-lit.',
              ),
              const _InstructionStep(
                number: '4.',
                text:
                    'Listen carefully to the instructions, take photos when prompted, and listen to the feedback.',
              ),
              const _InstructionStep(
                number: '5.',
                text: 'Tap the "Start" button to begin.',
              ),

              const SizedBox(height: 30),
              Divider(color: accentGreen, thickness: 2),
              const SizedBox(height: 10),

              const Text(
                '👉 Next, you will be asked to select a recipe to start.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor,
                ),
              ),

              const SizedBox(height: 40),

              // Centered buttons
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KitchenRecipeSelectPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                      child: const Text('Start'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SavedRecipesPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        side: const BorderSide(color: accentGreen, width: 2),
                        foregroundColor: accentGreen,
                      ),
                      child: const Text('Select from Saved Recipes'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// A helper widget to ensure consistent accessible text styling for steps.
class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;
  const _InstructionStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$number ',
              style: const TextStyle(
                color: Color(0xFFFFA500), // orange for numbers
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: text,
              style: const TextStyle(
                color: Colors.white, // white text for readability
                fontSize: 18,
                height: 1.4, // improves readability and line spacing
              ),
            ),
          ],
        ),
      ),
    );
  }
}
