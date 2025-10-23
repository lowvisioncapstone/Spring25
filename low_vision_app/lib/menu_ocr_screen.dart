import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class MenuOCRScreen extends StatefulWidget {
  const MenuOCRScreen({super.key});

  @override
  State<MenuOCRScreen> createState() => _MenuOCRScreenState();
}

class _MenuOCRScreenState extends State<MenuOCRScreen> {
  File? _imageFile;
  String _resultText = '';
  final _picker = ImagePicker();
  final _tts = FlutterTts();

  
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _foodChoice = "";
  String? _pendingChoice; 
  final TextEditingController _foodController = TextEditingController();

  final String apiUrl = 'http://128.180.121.231:5010/upload';

  bool _isConfirming = false;

  bool _loading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      askFoodChoice();
    });
  }

  Future<void> askFoodChoice() async {
    await _tts.stop(); 
    await _speak("What food would you like to eat?");

    final bool available = await _speech.initialize(
      onStatus: (status) => debugPrint("Speech status: $status"),
      onError: (error) => debugPrint("Speech error: $error"),
    );

    if (available) {
      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          setState(() {
            _foodChoice = words;
            _foodController.text = words; 
          });
          debugPrint("User said: $_foodChoice");
        },
      );
    } else {
      debugPrint("Speech recognition not available");
      setState(() {
        _resultText = "Voice input temporarily unavailable.";
      });
    }
  }


  Future<void> captureAndSendImage() async {
    try {
      await http.post(
        Uri.parse('http://128.180.121.231:5010/repo'),
        headers: {'Content-Type': 'text/plain'},
        body: 'text',
      );
    } catch (e) {
      debugPrint('Error sending repo signal: $e');
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera); 

    if (pickedFile == null) {
      debugPrint('No image captured.');
      return;
    }

    setState(() {
      _imageFile = File(pickedFile.path);
      _resultText = '';
      _loading = true;
    });

    final uri = Uri.parse(apiUrl);
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      pickedFile.path,
      filename: basename(pickedFile.path),
    ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBytes = await response.stream.toBytes();
        final String responseText = String.fromCharCodes(responseBytes);
        debugPrint('Received text: $responseText');

        setState(() {
          _resultText = responseText;
        });

        await _speak(responseText);
      } else {
        debugPrint('Upload failed with status: ${response.statusCode}');
        setState(() {
          _resultText = 'Upload failed: ${response.statusCode}';
        });
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      setState(() {
        _resultText = 'Error uploading image: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false; 
        });
      }
    }
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  void _submitFoodChoice() async {
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
      await _speak("You said $_pendingChoice. Is this correct? If not, please retry.");
    } else {
      setState(() {
        _foodChoice = _pendingChoice ?? currentChoice;
        _resultText = "✅ Food choice saved: $_foodChoice";
        _isConfirming = false;
        _pendingChoice = null;
      });
      debugPrint("Final food choice confirmed: $_foodChoice");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu OCR')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        //child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
        child: ListView(
          children: [
            const Text(
              "What food would you like to eat?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _foodController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Type or speak your answer",
              ),
              onChanged: (value) {
                setState(() {
                  _foodChoice = value;
                  if (_isConfirming && value != _pendingChoice) {
                    _isConfirming = false;
                    _pendingChoice = null;
                    _resultText = "";
                  }
                });
              },
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: askFoodChoice,
              icon: const Icon(Icons.mic),
              label: const Text("Say Answer Again"),
            ),
            const SizedBox(height: 10),

            
            ElevatedButton.icon(
              onPressed: _submitFoodChoice,
              icon: const Icon(Icons.check),
              label: const Text("Submit Answer"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 20),

            if (_foodChoice.isNotEmpty)
              Text("Current choice: $_foodChoice",
                  style: const TextStyle(fontSize: 18, color: Colors.blue)),

            const Divider(height: 40),

          ElevatedButton.icon(
            onPressed: _loading ? null : captureAndSendImage, 
            icon: const Icon(Icons.photo_camera),
            label: const Text("Take Photo & Recognize"),
          ),
          const SizedBox(height: 16),


            if (_imageFile != null) Image.file(_imageFile!, height: 200),
            const SizedBox(height: 20),
            Text(_resultText, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
