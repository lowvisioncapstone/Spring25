import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter_tts/flutter_tts.dart';

class CameraPage extends StatefulWidget {
  final List<dynamic> ingredientList;
  const CameraPage({super.key, required this.ingredientList});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _imageFile;
  String _resultText = '';
  final _picker = ImagePicker();
  final _tts = FlutterTts();

  final String apiUrl = 'http://128.180.121.231:5010/upload'; //app server

  @override
  void initState() {
    super.initState();
    // Open camera automatically after a short delay
    Future.delayed(Duration(milliseconds: 300), captureAndSendImage);
  }

  Future<void> captureAndSendImage() async {
    // optional "signal" to backend
    try {
      await http.post(
        Uri.parse('http://128.180.121.231:5010/repo'),
        headers: {'Content-Type': 'text/plain'},
        body: 'object',
      );
    } catch (e) {
      print('Error sending repo signal: $e');
    }

    // open camera
     final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      // If user cancels camera, go back
      Navigator.pop(context);
      return;
    }

    setState(() {
      _imageFile = File(pickedFile.path);
      _resultText = 'Processing...';
    });

    final uri = Uri.parse(apiUrl);
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      pickedFile.path,
      filename: p.basename(pickedFile.path),
    ));

    request.fields['ingredients'] = widget.ingredientList.join('\n');

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBytes = await response.stream.toBytes();
        final responseText = String.fromCharCodes(responseBytes);

        setState(() => _resultText = responseText);
        await _speak(responseText);
      } else {
        setState(() => _resultText = 'Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _resultText = 'Error uploading image: $e');
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
      appBar: AppBar(title: const Text('Camera Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: captureAndSendImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Camera'),
            ),
            const SizedBox(height: 20),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 250),
            const SizedBox(height: 20),
            Text(
              _resultText,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}