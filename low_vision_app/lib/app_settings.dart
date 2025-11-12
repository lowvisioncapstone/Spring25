import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static bool enableTTS = true;
  static bool enableSTT = true;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    enableTTS = prefs.getBool("enableTTS") ?? true;
    enableSTT = prefs.getBool("enableSTT") ?? true;
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("enableTTS", enableTTS);
    await prefs.setBool("enableSTT", enableSTT);
  }
}
