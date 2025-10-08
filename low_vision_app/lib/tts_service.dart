// lib/services/tts_service.dart
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._internal();
  static final TtsService instance = TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _inited = false;
  bool _isSpeaking = false;

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

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);

    _inited = true;
  }

  Future<void> speak(String text) async {
    await init();
    if (text.trim().isEmpty) return;
    if (_isSpeaking) {
      await _tts.stop();
    }
    await _tts.speak(text);
  }

  Future<void> speakLines(List<String> lines, {Duration gap = const Duration(milliseconds: 300)}) async {
    await init();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      await speak(line);
      while (_isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 100));
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
  }

  Future<void> resume() async {
    await _tts.resume();
  }

  bool get isSpeaking => _isSpeaking;
}
