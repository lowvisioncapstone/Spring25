import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'app_settings.dart';
import 'dart:convert';

// ---- DIO COOKIE MANAGER ----
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

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
  final TextEditingController _allergiesCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  bool _is21 = false; // NEW — replaces DOB text field entirely

  final TextEditingController _usernameCtrl = TextEditingController();
final TextEditingController _passwordCtrl = TextEditingController();

bool _showPassword = false;

  final String foodUrl = 'http://128.180.121.231:5010/get_profile';

  late Dio dio;

  @override
  void initState() {
    super.initState();
    AppSettings.load().then((_) => setState(() {}));
    _loadProfile();
    speech.initialize();
    _initDio();
  }

  // ---------------- DIO + COOKIE MANAGER SETUP ----------------
  Future<void> _initDio() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
        storage: FileStorage("${appDir.path}/cookies_profile"));

    dio = Dio(BaseOptions(
      baseUrl: "http://128.180.121.231:5010",
      headers: {"Content-Type": "application/json"},
    ));

    dio.interceptors.add(CookieManager(cookieJar));
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

  // ---------------- LOAD PROFILE ----------------
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _nameCtrl.text = prefs.getString("name") ?? "";
      _countryCtrl.text = prefs.getString("country") ?? "";
      _allergiesCtrl.text = prefs.getString("allergies") ?? "";
      _emailCtrl.text = prefs.getString("email") ?? "";
      _phoneCtrl.text = prefs.getString("phone") ?? "";
      _is21 = prefs.getBool("is21") ?? false;

    _usernameCtrl.text = prefs.getString("username") ?? "";
    _passwordCtrl.text = prefs.getString("password") ?? "";
    });

    await _speak("Profile loaded. You can start editing your information.");
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", _nameCtrl.text);
    await prefs.setString("country", _countryCtrl.text);
    await prefs.setString("allergies", _allergiesCtrl.text);
    await prefs.setString("email", _emailCtrl.text);
    await prefs.setString("phone", _phoneCtrl.text);
    await prefs.setBool("is21", _is21);

    await prefs.setString("username", _usernameCtrl.text);
    await prefs.setString("password", _passwordCtrl.text);

    // Address removed → send null to keep backend schema valid
    final Map<String, dynamic> profileData = {
      "name": _nameCtrl.text,
      "country": _countryCtrl.text,
      "address": null,       // <-- stays in JSON but empty
      "allergies": _allergiesCtrl.text,
      "email": _emailCtrl.text,
      "is_21": _is21,        // <-- replaces DOB
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC20A),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (!confirm) return;

    try {
      final response = await dio.post(
        "/get_profile",
        data: jsonEncode(profileData),
        options: Options(
          contentType: "application/json",
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        _speak("Profile saved and uploaded successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile uploaded successfully!")),
        );
      } else {
        _speak("Profile saved locally, but upload failed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Server error: ${response.statusCode}")),
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
    final highContrastAccent = const Color(0xFFFFC20A);
    final highContrastFieldBg = const Color(0xFF1C1C1C);

    return Scaffold(
      backgroundColor: highContrastBg,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        title: const Text(
          "Accessible User Profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      // ---------------- UI ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_circle,
                  size: 100, color: Colors.orange),
              const SizedBox(height: 20),

              Text("Personal Information",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white, thickness: 2),

              buildTextField("Name", _nameCtrl, highContrastText,
                  highContrastFieldBg, Colors.orange),

              buildTextField("Country", _countryCtrl, highContrastText,
                  highContrastFieldBg, Colors.orange),


              buildTextField(
                  "Do you have any allergies?",
                  _allergiesCtrl,
                  highContrastText,
                  highContrastFieldBg,
                  Colors.orange),

              const SizedBox(height: 20),

              Text("Contact Information",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white, thickness: 2),

              // ---------------- USERNAME (READ ONLY) ----------------
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: _usernameCtrl,
                  readOnly: true,                      // <-- cannot edit
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: highContrastFieldBg,
                    labelText: "Username",
                    labelStyle: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // ---------------- PASSWORD (READ ONLY + TOGGLE) ----------------
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: _passwordCtrl,
                  readOnly: true,                        // <-- cannot edit
                  obscureText: !_showPassword,           // <-- hides text unless toggled
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: highContrastFieldBg,
                    labelText: "Password",
                    labelStyle: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;   // <-- toggles visibility
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),


              buildTextField("Email", _emailCtrl, highContrastText,
                  highContrastFieldBg, Colors.orange,
                  type: TextInputType.emailAddress),

              // ---------- AGE CHECKBOX ----------
              CheckboxListTile(
                title: Text("Are you 21 or older?",
                    style: TextStyle(color: Colors.orange, fontSize: 18)),
                value: _is21,
                activeColor: Colors.orange,
                checkColor: Colors.black,
                onChanged: (val) async{
                  setState(() => _is21 = val ?? false);
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool("is21", _is21);
                },
              ),

              buildTextField("Phone Number", _phoneCtrl, highContrastText,
                  highContrastFieldBg, Colors.orange,
                  type: TextInputType.phone),

              const SizedBox(height: 30),

              SwitchListTile(
                title: Text("Enable Text-to-Speech",
                    style: TextStyle(color: Colors.orange, fontSize: 18)),
                value: AppSettings.enableTTS,
                activeColor: Colors.orange,
                onChanged: (val) {
                  setState(() => AppSettings.enableTTS = val);
                  AppSettings.save();
                },
              ),

              SwitchListTile(
                title: Text("Enable Speech-to-Text",
                    style: TextStyle(color: Colors.orange, fontSize: 18)),
                value: AppSettings.enableSTT,
                activeColor: Colors.orange,
                onChanged: (val) {
                  setState(() => AppSettings.enableSTT = val);
                  AppSettings.save();
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveProfile,
                icon:
                    const Icon(Icons.save, size: 26, color: Colors.black),
                label: const Text("Save Profile",
                    style: TextStyle(color: Colors.black)),
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
        style: TextStyle(
            fontSize: 20,
            color: textColor,
            fontWeight: FontWeight.w600),
        cursorColor: accentColor,
        decoration: InputDecoration(
          filled: true,
          fillColor: fieldBg,
          labelText: label,
          labelStyle: TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold),
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
