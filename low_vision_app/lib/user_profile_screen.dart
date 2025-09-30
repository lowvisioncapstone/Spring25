import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'app_settings.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  final _formKey = GlobalKey<FormState>();

  // text controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _allergiesCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppSettings.load().then((_) {
      setState(() {});
    });
    _loadProfile();
    speech.initialize();
  }

  Future<void> _speak(String text) async {
    if (AppSettings.enableTTS) {
      await flutterTts.speak(text);
    }
  }

  String _cleanupEmail(String input) {
    return input
        .replaceAll(RegExp(r"\bat\b", caseSensitive: false), "@")
        .replaceAll(RegExp(r"\bdot\b", caseSensitive: false), ".")
        .replaceAll(RegExp(r"\bunderscore\b", caseSensitive: false), "_")
        .replaceAll(" ", "")
        .trim();
  }

  String _cleanupPhone(String input) {
    String cleaned = input
        .replaceAll(RegExp(r"\bdash\b", caseSensitive: false), "-")
        .replaceAll(RegExp(r"\bspace\b", caseSensitive: false), "")
        .replaceAll(RegExp(r"\bplus\b", caseSensitive: false), "+")
        .replaceAll(RegExp(r"\bzero\b", caseSensitive: false), "0")
        .replaceAll(RegExp(r"\bone\b", caseSensitive: false), "1")
        .replaceAll(RegExp(r"\btwo\b", caseSensitive: false), "2")
        .replaceAll(RegExp(r"\bthree\b", caseSensitive: false), "3")
        .replaceAll(RegExp(r"\bfour\b", caseSensitive: false), "4")
        .replaceAll(RegExp(r"\bfive\b", caseSensitive: false), "5")
        .replaceAll(RegExp(r"\bsix\b", caseSensitive: false), "6")
        .replaceAll(RegExp(r"\bseven\b", caseSensitive: false), "7")
        .replaceAll(RegExp(r"\beight\b", caseSensitive: false), "8")
        .replaceAll(RegExp(r"\bnine\b", caseSensitive: false), "9");

    // Keep only digits, + and -
    cleaned = cleaned.replaceAll(RegExp(r"[^0-9+-]"), "");
    return cleaned.trim();
  }

  Future<void> _listen(
      TextEditingController controller, String label) async {
    if (!AppSettings.enableSTT) return;
    bool available = await speech.initialize();
    if (available) {
      await speech.listen(onResult: (result) async {
        String spoken = result.recognizedWords;

        if (label.toLowerCase().contains("email")) {
          spoken = _cleanupEmail(spoken);
        } else if (label.toLowerCase().contains("phone")) {
          spoken = _cleanupPhone(spoken);
        }

        controller.text = spoken;

        if (result.finalResult) {
          await speech.stop();
          _speak("You said ${controller.text}");
          setState(() {});
        }
      });
    }
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString("name") ?? "";
      _countryCtrl.text = prefs.getString("country") ?? "";
      _addressCtrl.text = prefs.getString("address") ?? "";
      _allergiesCtrl.text = prefs.getString("allergies") ?? "";
      _emailCtrl.text = prefs.getString("email") ?? "";
      _dobCtrl.text = prefs.getString("dob") ?? "";
      _phoneCtrl.text = prefs.getString("phone") ?? "";
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", _nameCtrl.text);
    await prefs.setString("country", _countryCtrl.text);
    await prefs.setString("address", _addressCtrl.text);
    await prefs.setString("allergies", _allergiesCtrl.text);
    await prefs.setString("email", _emailCtrl.text);
    await prefs.setString("dob", _dobCtrl.text);
    await prefs.setString("phone", _phoneCtrl.text);
    _speak("Profile saved successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: const Color(0xFF99ccff),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Name", _nameCtrl),
              buildTextField("Country", _countryCtrl),
              buildTextField("Home Address", _addressCtrl),
              buildTextField("Do you have any allergies?", _allergiesCtrl),
              buildTextField("Email", _emailCtrl,
                  type: TextInputType.emailAddress),
              buildTextField("Date of Birth", _dobCtrl),
              buildTextField("Phone Number", _phoneCtrl,
                  type: TextInputType.phone),

              const SizedBox(height: 30),
              // Switches for TTS / STT
              SwitchListTile(
                title: const Text("Enable Text-to-Speech"),
                value: AppSettings.enableTTS,
                onChanged: (val) {
                  setState(() => AppSettings.enableTTS = val);
                  AppSettings.save();
                },
              ),
              SwitchListTile(
                title: const Text("Enable Speech-to-Text"),
                value: AppSettings.enableSTT,
                onChanged: (val) {
                  setState(() => AppSettings.enableSTT = val);
                  AppSettings.save();
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        onTap: () async {
          await _speak(label);
          // wait a little so it doesn’t capture its own voice
          Future.delayed(const Duration(seconds: 2), () {
            _listen(controller, label);
          });
        },
      ),
    );
  }
}
