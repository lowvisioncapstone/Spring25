import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart';

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

  final String apiUrl = 'http://128.180.121.231:5010/upload';

  Future<void> captureAndSendImage() async {
    final picker = ImagePicker();

    try {
      final preSignalResponse = await http.post(
        Uri.parse('http://128.180.121.231:5010/repo'),
        headers: {'Content-Type': 'text/plain'},
        body: 'text',
      );
    } catch (e) {
      print('Error sending repo signal: $e');
    }

    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      print('No image captured.');
      return;
    }

    setState(() {
      _imageFile = File(pickedFile.path);
    });

    final uri = Uri.parse('http://128.180.121.231:5010/upload');
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
        String responseText = String.fromCharCodes(responseBytes);
        print('Received text: $responseText');

        setState(() {
          _resultText = responseText;
        });
      } else {
        print('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        _resultText = 'Error uploading image: $e';
      });
    }
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
              onPressed: captureAndSendImage,
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
