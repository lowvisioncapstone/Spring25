import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

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

  final String apiUrl =
      'http://128.180.121.231:5000/extract_text'; // Replace with your actual IP

  Future<void> _takePhotoAndRecognize() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadAndRecognize(File(pickedFile.path));
    }
  }

  Future<void> _uploadAndRecognize(File image) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final text = _extractTextFromJson(responseBody);
        setState(() => _resultText = text);
        _speak(text);
      } else {
        setState(() => _resultText = 'Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _resultText = 'Failed to connect to server.');
    }
  }

  String _extractTextFromJson(String jsonStr) {
    final match = RegExp(r'"extracted_text"\s*:\s*"(.+?)"').firstMatch(jsonStr);
    return match != null ? match.group(1) ?? '' : 'No text found.';
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu OCR')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _takePhotoAndRecognize,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
            const SizedBox(height: 20),
            if (_imageFile != null) Image.file(_imageFile!, height: 200),
            const SizedBox(height: 20),
            Text(_resultText, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
