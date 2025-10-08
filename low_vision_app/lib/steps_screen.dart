import 'package:flutter/material.dart';
import 'tts_service.dart';

class StepsScreen extends StatefulWidget {
  final String title;
  final String instructions;

  const StepsScreen({
    super.key,
    required this.title,
    required this.instructions,
  });

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  late List<String> steps;
  int currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    // Split instructions into steps using period or newline
    steps = widget.instructions
        .split(RegExp(r'\. |\n')) // You can refine this further
        .where((step) => step.trim().isNotEmpty)
        .toList();
      if(steps.isNotEmpty){
        TtsService.instance.speak('Step 1. ${steps[0].trim()}');
      }
  }

  @override
  void dispose(){
    TtsService.instance.stop();
    super.dispose();
  }

  void _nextStep() {
    if (currentStepIndex < steps.length - 1) {
      setState(() {
        currentStepIndex++;
      });
      TtsService.instance.speak('Step ${currentStepIndex + 1}. ${steps[currentStepIndex].trim()}');
    }
  }

  void _prevStep() {
    if (currentStepIndex > 0) {
      setState(() {
        currentStepIndex--;
      });
      TtsService.instance.speak('Step ${currentStepIndex + 1}. ${steps[currentStepIndex].trim()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = steps[currentStepIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Step ${currentStepIndex + 1} of ${steps.length}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  currentStep.trim(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentStepIndex > 0 ? _prevStep : null,
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed:()=> TtsService.instance.speak('Step ${currentStepIndex + 1}. ${steps[currentStepIndex].trim()}',),
                  child: const Text('Speak'),
                ),
                ElevatedButton(
                  onPressed:()=> TtsService.instance.stop(),
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: currentStepIndex < steps.length - 1 ? _nextStep : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
