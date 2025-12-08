import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

class MenuOCRScreen extends StatefulWidget {
  const MenuOCRScreen({super.key});

  @override
  State<MenuOCRScreen> createState() => _MenuOCRScreenState();
}

class _MenuOCRScreenState extends State<MenuOCRScreen> {
  File? _imageFile;
  String? _menuText;
  bool _menuReady = false;
  bool _menuRead = false;
  String _resultText = '';
  String _foodChoice = "";
  String? _pendingChoice;
  bool _isConfirming = false;

  final _picker = ImagePicker();
  final _tts = FlutterTts();
  final _speech = stt.SpeechToText();
  final TextEditingController _foodController = TextEditingController();

  late Dio dio;

  final String baseUrl = 'http://128.180.121.231:5010';

  List<Map<String, dynamic>> savedMenus = [];

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadSavedMenus();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (AppSettings.enableTTS) {
        await _speak("Please scan the menu to continue.");
      }
    });
  }

  Future<void> _setupDio() async {
    final dir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/cookies'),
    );

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  // ---------------- IMAGE CAPTURE + UPLOAD ----------------

  Future<void> captureAndSendImage() async {
    if (AppSettings.enableTTS) {
      await _speak("Opening camera. Please hold your phone steady.");
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      if (AppSettings.enableTTS) {
        await _speak("No image captured. Please try again.");
      }
      return;
    }

    setState(() {
      _imageFile = File(pickedFile.path);
      _menuReady = false;
      _menuText = null;
    });

    try {
      await dio.post(
        '/repo',
        data: 'text',
        options: Options(
          contentType: Headers.textPlainContentType,
        ),
      );
    } catch (e) {
      debugPrint("Repo pre-signal error: $e");
    }

    try {
      if (AppSettings.enableTTS) {
        await _speak("Uploading image. Please wait.");
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          pickedFile.path,
          filename: basename(pickedFile.path),
        ),
      });

      final response = await dio.post('/upload', data: formData);

      if (response.statusCode == 200) {
        setState(() {
          _menuText = response.data.toString();
          _menuReady = true;
        });

        if (AppSettings.enableTTS) {
          await _speak("Menu scanned successfully.");
        }

        await askFoodChoice();
      } else {
        if (AppSettings.enableTTS) {
          await _speak("Failed to upload image.");
        }
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (AppSettings.enableTTS) {
        await _speak("There was an error uploading the image.");
      }
    }
  }

  // ---------------- FOOD CHOICE ----------------

  Future<void> askFoodChoice() async {
    if (AppSettings.enableTTS) {
      await _speak("What food would you like to eat?");
    }

    if (AppSettings.enableSTT) {
      bool available = await _speech.initialize();
      if (available) {
        await Future.delayed(const Duration(seconds: 2));
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _foodChoice = result.recognizedWords;
              _foodController.text = _foodChoice;
            });
          },
        );
      }
    }
  }

  void _submitFoodChoice(BuildContext context) async {
    final currentChoice = _foodController.text.trim();

    if (_isConfirming && currentChoice != _pendingChoice) {
      setState(() {
        _isConfirming = false;
        _pendingChoice = null;
      });
    }

    if (!_isConfirming) {
      setState(() {
        _pendingChoice = currentChoice;
        _isConfirming = true;
        _resultText =
            "You said: $_pendingChoice\nPress Submit again to confirm, or edit to retry.";
      });

      if (AppSettings.enableTTS) {
        _speak("You said $_pendingChoice. Press submit again to confirm.");
      }
    } else {
      final confirmed = _pendingChoice ?? currentChoice;

      setState(() {
        _foodChoice = confirmed;
        _isConfirming = false;
        _pendingChoice = null;
        _resultText = "✅ Food choice saved: $_foodChoice\nWaiting for response...";
      });

      try {
        // ------------------ DEBUG: Check cookies ------------------
        if (dio.interceptors.isNotEmpty) {
          final cookieManager = dio.interceptors
              .firstWhere((i) => i is CookieManager) as CookieManager;
          final cookies = await cookieManager.cookieJar
              .loadForRequest(Uri.parse('$baseUrl/food_selection'));
          debugPrint("🔹 Cookies being sent to /food_selection: $cookies");
        }

        debugPrint("🔹 Sending food selection: $confirmed");

        final response = await dio.post(
          '/food_selection',
          data: {'choice': confirmed},
          options: Options(
            validateStatus: (status) {
              debugPrint("🔹 Response status: $status");
              return true; // allow all status codes so we can see them
            },
          ),
        );

        debugPrint("🔹 Response data: ${response.data}");

        if (response.statusCode == 200) {
          final responseText = response.data.toString();

          setState(() {
            _resultText =
                "✅ Food choice saved: $_foodChoice\n\nResponse:\n$responseText";
          });

          if (AppSettings.enableTTS) {
            await _speak(responseText);
          }

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Food Selection Response"),
              content: SingleChildScrollView(child: Text(responseText)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                )
              ],
            ),
          );
        } else {
          setState(() {
            _resultText =
                "❌ Food choice failed. Status code: ${response.statusCode}\n${response.data}";
          });
        }
      } catch (e) {
        debugPrint("Food choice error: $e");
        setState(() {
          _resultText = "❌ Error sending food choice.";
        });
        if (AppSettings.enableTTS) {
          _speak("There was an error sending your food choice.");
        }
      }
    }
  }


  // ---------------- MENU STORAGE ----------------

  Future<void> _loadSavedMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_menus') ?? [];
    setState(() {
      savedMenus = saved.map((e) => {"text": e}).toList();
    });
  }

  Future<void> _saveCurrentMenu(BuildContext context) async {
    if (_menuText == null || _menuText!.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('saved_menus') ?? [];

    String entry = "${DateTime.now().toLocal()}:\n${_menuText!.trim()}";
    saved.add(entry);

    await prefs.setStringList('saved_menus', saved);

    setState(() {
      savedMenus.add({"text": entry});
      _menuRead = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Menu saved locally")),
    );

    if (AppSettings.enableTTS) {
      await _speak("Menu saved successfully.");
    }
  }

  // ---------------- READ MENU ----------------

  void _readMenu(BuildContext context) async {
    if (_menuReady && _menuText != null) {
      if (AppSettings.enableTTS) {
        await _speak("Reading the menu now.");
      }

      await _speak(_menuText!);

      setState(() {
        _menuRead = true;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Menu"),
          content: SingleChildScrollView(child: Text(_menuText!)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            )
          ],
        ),
      );
    } else {
      final msg = "Menu is still processing...";
      if (AppSettings.enableTTS) _speak(msg);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // ---------------- UI ----------------

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 40),
      label: Text(
        label,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu OCR',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellowAccent,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildButton(
                label: "Scan Menu",
                icon: Icons.camera_alt,
                color: Colors.black,
                onPressed: captureAndSendImage,
              ),
              const SizedBox(height: 25),
              _buildButton(
                label: "Read Menu",
                icon: Icons.volume_up,
                color: Colors.orange,
                onPressed: () => _readMenu(context),
              ),
              if (_menuRead)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _buildButton(
                    label: "Save Menu",
                    icon: Icons.save,
                    color: Colors.green,
                    onPressed: () => _saveCurrentMenu(context),
                  ),
                ),
              const Divider(height: 40, color: Colors.white70),
              TextField(
                controller: _foodController,
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "Type or say your food choice",
                  hintStyle:
                      const TextStyle(color: Colors.white54, fontSize: 22),
                ),
              ),
              const SizedBox(height: 20),
              _buildButton(
                label: "Submit Answer",
                icon: Icons.check_circle,
                color: Colors.green,
                onPressed: () => _submitFoodChoice(context),
              ),
              const SizedBox(height: 20),
              Text(
                _resultText,
                style:
                    const TextStyle(fontSize: 22, color: Colors.white),
              ),
              if (savedMenus.isNotEmpty) ...[
                const Divider(color: Colors.white70),
                const Text(
                  "Saved Menus:",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent),
                ),
                for (var menu in savedMenus.reversed)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      border: Border.all(color: Colors.white70),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      menu["text"] ?? "",
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          height: 1.4),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}