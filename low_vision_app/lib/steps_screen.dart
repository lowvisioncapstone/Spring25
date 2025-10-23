import 'package:flutter/material.dart';
import 'tts_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  int get _totalSteps => steps.length;
  int get _currentStep => currentStepIndex;

  bool get _needsScan {
    if (_currentStep < 0 || _currentStep >= _totalSteps) return false;
    final text = steps[_currentStep].toLowerCase();
    return text.contains('scan');
  }

  @override
  void initState() {
    super.initState();
    // Split instructions into steps using period or newline
    final raw = widget.instructions
        .split(RegExp(r'(\n+|\. +)'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    steps = raw;
      if(steps.isNotEmpty){
        TtsService.instance.speak('Step 1. ${steps[0].trim()}');
      }
  }

  @override
  void dispose(){
    TtsService.instance.stop();
    super.dispose();
  }

  void _speakCurrent() {
    if (_currentStep >= 0 && _currentStep < _totalSteps) {
      final text = 'Step ${_currentStep + 1}. ${steps[_currentStep]}';
      TtsService.instance.speak(text);
    }
  }

  void _nextStep() {
    /*if (currentStepIndex < steps.length - 1) {
      setState(() {
        currentStepIndex++;
      });
      TtsService.instance.speak('Step ${currentStepIndex + 1}. ${steps[currentStepIndex].trim()}');
    }*/
    if (currentStepIndex < steps.length - 1) {
      setState(() => currentStepIndex++);
      TtsService.instance.stop();
      _speakCurrent();
    }
  }

  void _prevStep() {
    /*if (currentStepIndex > 0) {
      setState(() {
        currentStepIndex--;
      });
      TtsService.instance.speak('Step ${currentStepIndex + 1}. ${steps[currentStepIndex].trim()}');
    }*/
    if (currentStepIndex > 0) {
      setState(() => currentStepIndex--);
      TtsService.instance.stop();
      _speakCurrent();
    }
  }

  void _endCooking() {
  showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('End cooking?'),
      content: const Text('Are you sure you want to end this session?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('End'),
        ),
      ],
    ),
  ).then((ok) {
    if (ok == true) {
      TtsService.instance.stop().whenComplete(() {
        if (!mounted) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    }
  });
  }

/*
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
}*/

  @override
  Widget build(BuildContext context) {
    final progress =
        _totalSteps == 0 ? 0.0 : (_currentStep + 1) / _totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // 
          IconButton(
            tooltip: 'End cooking',
            onPressed: _endCooking,
            icon: const Icon(Icons.stop_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of $_totalSteps',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${(progress * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress, minHeight: 6),
              const SizedBox(height: 16),

              if (_totalSteps > 0)
                Text(
                  steps[_currentStep],
                  style: const TextStyle(fontSize: 18),
                )
              else
                const Text('No steps found.'),

              const Spacer(),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _prevStep,
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: _speakCurrent,
                    child: const Text('Speak'),
                  ),
                  ElevatedButton(
                    onPressed: () => TtsService.instance.stop(),
                    child: const Text('Stop'),
                  ),

                  // Read again
                  ElevatedButton.icon(
                    onPressed: _speakCurrent,
                    icon: const Icon(Icons.replay),
                    label: const Text('Read again'),
                  ),

                  // Skip
                  if (_needsScan)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await TtsService.instance.stop();
                        _nextStep();
                      },
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Skip'),
                    ),

                  ElevatedButton(
                    onPressed: currentStepIndex < steps.length - 1
                        ? _nextStep
                        : null,
                    child: const Text('Next'),
                  ),

                  // End cooking
                  ElevatedButton.icon(
                    onPressed: _endCooking,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('End'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
