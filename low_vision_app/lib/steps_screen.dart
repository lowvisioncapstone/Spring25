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
    const backgroundColor = Colors.black;
    const primaryTextColor = Colors.white;
    const accentTextColor = Color(0xFFFFA500); // orange
    const accentGreen = Color(0xFF00C853); // accessible green

    final progress =
        _totalSteps == 0 ? 0.0 : (_currentStep + 1) / _totalSteps;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: accentTextColor,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'End cooking',
            onPressed: _endCooking,
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress + Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of $_totalSteps',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: accentTextColor,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(color: primaryTextColor, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: accentGreen,
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(height: 20),

              // Step text box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentGreen, width: 1.5),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _totalSteps > 0
                          ? steps[_currentStep]
                          : 'No steps found.',
                      style: const TextStyle(
                        color: primaryTextColor,
                        fontSize: 20,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Top row of buttons: Speak, Stop, Read again
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: _speakCurrent,
                    icon: const Icon(Icons.volume_up, size: 18),
                    label: const Text('Speak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => TtsService.instance.stop(),
                    icon: const Icon(Icons.stop, size: 18),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _speakCurrent,
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Read Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  if (_needsScan)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await TtsService.instance.stop();
                        _nextStep();
                      },
                      icon: const Icon(Icons.skip_next, size: 18),
                      label: const Text('Skip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Bottom row: Back + Next
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: OutlinedButton.icon(
                      onPressed: _prevStep,
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                      label: const Text(
                        'Back',
                        style: TextStyle(
                          // color: accentGreen,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 26),
                        textStyle: const TextStyle(fontSize: 16),
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: currentStepIndex < steps.length - 1
                          ? _nextStep
                          : null,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 26),
                        textStyle: const TextStyle(fontSize: 16),
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
