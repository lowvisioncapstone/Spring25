import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter_tts/flutter_tts.dart';

class BoilDetectorPage extends StatefulWidget {
  const BoilDetectorPage({super.key});

  @override
  State<BoilDetectorPage> createState() => _BoilDetectorPageState();
}

class _BoilDetectorPageState extends State<BoilDetectorPage> {
  File? _imageFile;
  String _resultText = '';
  final _picker = ImagePicker();
  final _tts = FlutterTts();

  ///  boil detection backend endpoint
  final String apiUrl = 'http://128.180.121.231:5010/upload';

  @override
  void initState() {
    super.initState();

    // Automatically open the camera
    Future.delayed(const Duration(milliseconds: 300), () {
      captureAndSendImage();
    });
  }

  Future<void> captureAndSendImage() async {
    try {
      await http.post(
        Uri.parse('http://128.180.121.231:5010/repo'),
        headers: {'Content-Type': 'text/plain'},
        body: 'boil',
      );
    } catch (e) {
      print('Error sending boil repo signal: $e');
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      Navigator.pop(context); // user canceled camera
      return;
    }

    setState(() {
      _imageFile = File(pickedFile.path);
      _resultText = "Analyzing...";
    });

    final uri = Uri.parse(apiUrl);
    final request = http.MultipartRequest("POST", uri);

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      pickedFile.path,
      filename: p.basename(pickedFile.path),
    ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final text = String.fromCharCodes(bytes);

        setState(() => _resultText = text);

        _speak(text);
      } else {
        setState(() => _resultText = "Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _resultText = "Upload failed: $e");
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
      appBar: AppBar(
        title: const Text("Boil Detector"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: captureAndSendImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Retake Photo"),
            ),
            const SizedBox(height: 20),

            if (_imageFile != null)
              Image.file(_imageFile!, height: 250),

            const SizedBox(height: 20),

            Text(
              _resultText,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
