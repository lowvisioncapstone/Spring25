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
    // Split instructions into steps by period or newline
    final raw = widget.instructions
        .split(RegExp(r'(\n+|\. +)'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    steps = raw;

    if (steps.isNotEmpty) {
      TtsService.instance.speak('Step 1. ${steps[0].trim()}');
    }
  }

  @override
  void dispose() {
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
    if (currentStepIndex < steps.length - 1) {
      setState(() => currentStepIndex++);
      TtsService.instance.stop();
      _speakCurrent();
    }
  }

  void _prevStep() {
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

  @override
  Widget build(BuildContext context) {
    final progress =
        _totalSteps == 0 ? 0.0 : (_currentStep + 1) / _totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'End cooking',
            onPressed: _endCooking,
            icon: const Icon(Icons.stop_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( // 👈 makes the whole page scrollable
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header + Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of $_totalSteps',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text('${(progress * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress, minHeight: 6),
              const SizedBox(height: 16),

              // Step Text
              if (_totalSteps > 0)
                Text(
                  steps[_currentStep],
                  style: const TextStyle(fontSize: 18, height: 1.4),
                )
              else
                const Text('No steps found.'),

              const SizedBox(height: 30),

              // Buttons section
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
                  ElevatedButton.icon(
                    onPressed: _speakCurrent,
                    icon: const Icon(Icons.replay),
                    label: const Text('Read again'),
                  ),
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
