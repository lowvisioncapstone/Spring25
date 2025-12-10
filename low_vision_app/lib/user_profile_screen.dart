import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'app_settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _allergiesCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  final String foodUrl = 'http://128.180.121.231:5010/get_profile';

  @override
  void initState() {
    super.initState();
    AppSettings.load().then((_) => setState(() {}));
    _loadProfile();
    speech.initialize();
  }

  Future<void> _speak(String text) async {
    if (AppSettings.enableTTS && text.isNotEmpty) {
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
    cleaned = cleaned.replaceAll(RegExp(r"[^0-9+-]"), "");
    return cleaned.trim();
  }

  Future<void> _listen(TextEditingController controller, String label) async {
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
          await _speak("You said ${controller.text}");
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
    await _speak("Profile loaded. You can start editing your information.");
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

    final Map<String, String> profileData = {
      "name": _nameCtrl.text,
      "country": _countryCtrl.text,
      "address": _addressCtrl.text,
      "allergies": _allergiesCtrl.text,
      "email": _emailCtrl.text,
      "dob": _dobCtrl.text,
      "phone": _phoneCtrl.text,
    };

    final bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF000000),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        title: const Text("Confirm Save"),
        content: const Text("Do you want to save and upload your profile?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC20A)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (!confirm) return;

    try {
      final response = await http.post(
        Uri.parse(foodUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        _speak("Profile saved and uploaded successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile uploaded successfully!")),
        );
      } else {
        _speak("Profile saved locally, but upload failed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      _speak("Profile saved locally, but network error occurred");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final highContrastBg = const Color(0xFF000000);
    final highContrastText = const Color(0xFFFFFFFF);
    final highContrastAccent = const Color(0xFFFFC20A); // Yellow (7.2:1 contrast)
    final highContrastFieldBg = const Color(0xFF1C1C1C);

    return Scaffold(
      backgroundColor: highContrastBg,
      appBar: AppBar(
        backgroundColor: highContrastAccent,
        foregroundColor: Colors.black,
        title: const Text(
          "Accessible User Profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Color(0xFFFFC20A)),
              const SizedBox(height: 20),
              Text(
                "Personal Information",
                style: TextStyle(
                  color: highContrastAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.white, thickness: 2),

              buildTextField("Name", _nameCtrl, highContrastText, highContrastFieldBg, highContrastAccent),
              buildTextField("Country", _countryCtrl, highContrastText, highContrastFieldBg, highContrastAccent),
              buildTextField("Home Address", _addressCtrl, highContrastText, highContrastFieldBg, highContrastAccent),
              buildTextField("Do you have any allergies?", _allergiesCtrl, highContrastText, highContrastFieldBg, highContrastAccent),

              const SizedBox(height: 20),
              Text(
                "Contact Information",
                style: TextStyle(
                  color: highContrastAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.white, thickness: 2),

              buildTextField("Email", _emailCtrl, highContrastText, highContrastFieldBg, highContrastAccent, type: TextInputType.emailAddress),
              buildTextField("Date of Birth", _dobCtrl, highContrastText, highContrastFieldBg, highContrastAccent),
              buildTextField("Phone Number", _phoneCtrl, highContrastText, highContrastFieldBg, highContrastAccent, type: TextInputType.phone),

              const SizedBox(height: 30),
              SwitchListTile(
                title: Text("Enable Text-to-Speech", style: TextStyle(color: highContrastText, fontSize: 18)),
                value: AppSettings.enableTTS,
                activeColor: highContrastAccent,
                onChanged: (val) {
                  setState(() => AppSettings.enableTTS = val);
                  AppSettings.save();
                },
              ),
              SwitchListTile(
                title: Text("Enable Speech-to-Text", style: TextStyle(color: highContrastText, fontSize: 18)),
                value: AppSettings.enableSTT,
                activeColor: highContrastAccent,
                onChanged: (val) {
                  setState(() => AppSettings.enableSTT = val);
                  AppSettings.save();
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: highContrastAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveProfile,
                icon: const Icon(Icons.save, size: 26, color: Colors.black),
                label: const Text("Save Profile", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    Color textColor,
    Color fieldBg,
    Color accentColor, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.w600),
        cursorColor: accentColor,
        decoration: InputDecoration(
          filled: true,
          fillColor: fieldBg,
          labelText: label,
          labelStyle: TextStyle(color: accentColor, fontSize: 18, fontWeight: FontWeight.bold),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentColor, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onTap: () async {
          await _speak(label);
          Future.delayed(const Duration(seconds: 1), () {
            _listen(controller, label);
          });
        },
      ),
    );
  }
}