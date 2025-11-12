// lib/tts_service.dart
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._internal();
  static final TtsService instance = TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _inited = false;
  bool _isSpeaking = false;
  String? _lastText;

  Future<void> init({
    String language = 'en-US',
    double rate = 0.45,
    double pitch = 1.0,
    double volume = 1.0,
  }) async {
    if (_inited) return;

    await _tts.setLanguage(language);
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
    await _tts.setVolume(volume);

    await _tts.awaitSpeakCompletion(true);

    _tts.setStartHandler(() {
      _isSpeaking = true;
    });
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });
    _tts.setCancelHandler(() {
      _isSpeaking = false;
    });
    _tts.setPauseHandler(() {
      _isSpeaking = false;
    });

    _inited = true;
  }

  Future<void> speak(String text) async {
    await init();
    final t = text.trim();
    if (t.isEmpty) return;

    _lastText = t;

    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await _tts.speak(t);
  }

  Future<void> speakLines(
    List<String> lines, {
    Duration gap = const Duration(milliseconds: 300),
  }) async {
    await init();
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      await speak(line);

      while (_isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 80));
      }
      await Future.delayed(gap);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> pause() async {
    await _tts.pause();
    _isSpeaking = false;
  }

  Future<void> resume() async {
    if (_lastText == null || _lastText!.isEmpty) return;
    await speak(_lastText!);
  }

  bool get isSpeaking => _isSpeaking;
}
