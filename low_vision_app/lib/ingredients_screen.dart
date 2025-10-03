import 'package:flutter/material.dart';
import 'steps_screen.dart'; 
import 'camera.dart';
import 'tts_service.dart';

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
              const SizedBox(width:12),
              ElevatedButton(
                onPressed:() async{
                  final lines = ingredients.map((e)=> e.toString()).toList();
                  if(lines.isNotEmpty){
                    await TtsService.instance.speak('Ingredients for $title.');
                    await TtsService.instance.speakLines(lines);
                  }
                },
                child: const Text('Read Ingredients'),
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
