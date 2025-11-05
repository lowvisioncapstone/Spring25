import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart';

class KitchenScanScreen extends StatefulWidget {
  final String recipeName;
  const KitchenScanScreen({super.key, required this.recipeName});

  @override
  State<KitchenScanScreen> createState() => _KitchenScanScreenState();
}

class _KitchenScanScreenState extends State<KitchenScanScreen> {
  File? _imageFile;
  File? _imageFile1;
  String _resultText = '';
  String _resultText1 = '';
  final _picker = ImagePicker();
  final _tts = FlutterTts();

  final String apiUrl =
      'http://128.180.121.231:5010/upload'; // Kitchen YOLO API

  bool _loading = false;

  Future<void> _uploadAndSpeak({
    required File imageFile,
    required void Function(String) onResult, 
  }) async {
    setState(() {
      _loading = true; 
    });
    try {
      final uri = Uri.parse(apiUrl);
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: basename(imageFile.path),
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBytes = await response.stream.toBytes();
        String responseText = String.fromCharCodes(responseBytes);

        setState(() {
          onResult(responseText); 
        });

        await _speak(responseText); 
      } else {
        setState(() {
          onResult('Upload failed: ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        onResult('Error uploading image: $e');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false; 
        });
      }
    }
  }

  Future<void> captureAndSendImage() async {
    try {
      final preSignalResponse = await http.post(
        Uri.parse('http://128.180.121.231:5010/repo'),
        headers: {'Content-Type': 'text/plain'},
        body: 'object',
      );
      
    } catch (e) {
      // ignore 
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _imageFile = File(pickedFile.path);
      _resultText = 'Processing...'; 
    });

    await _uploadAndSpeak(
      imageFile: _imageFile!,
      onResult: (text) => _resultText = text, 
    );
  }

  Future<void> captureAndSendImage2() async { 
    try {
      final preSignalResponse = await http.post(
        Uri.parse('http://128.180.121.231:5010/repo'),
        headers: {'Content-Type': 'text/plain'},
        body: 'object',
      );
    } catch (e) {
      // ignore
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) {
      return;
    }

    setState(() {
      _imageFile1 = File(pickedFile.path);
      _resultText1 = 'Processing...'; 
    });

    await _uploadAndSpeak(
      imageFile: _imageFile1!,
      onResult: (text) => _resultText1 = text, 
    );
  }

  Future<void> _speak(String text) async {
    await _tts.stop(); 
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    
    final page = Scaffold(
      appBar: AppBar(title: const Text('Kitchen Scan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView( 
          children: [
            const Text(
              'Step 1: Take a photo of your vegetable drawer!', //remove this later and put in own page
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: captureAndSendImage,
              icon: const Icon(Icons.kitchen),
              label: const Text('Scan vegetables'),
            ),
            const SizedBox(height: 20),
            if (_imageFile != null) Image.file(_imageFile!, height: 200),
            const SizedBox(height: 20),
            Text(_resultText, style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 32),

            const Text(
              'Step 2: Take a photo of your knife rack or utensils drawer!', //remove this later and put in own page
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: captureAndSendImage2, 
              icon: const Icon(Icons.kitchen),
              label: const Text('Scan Kitchen utensils'),
            ),
            const SizedBox(height: 20),
            if (_imageFile1 != null) Image.file(_imageFile1!, height: 200),
            const SizedBox(height: 20),
            Text(_resultText1, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        page,
        if (_loading) 
          Container(
            // color: Colors.black.withValues(alpha: 0.25),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}


/*
  Future<void> captureAndSendImage() async {
    try {
      final preSignalResponse = await http.post(
        Uri.parse('http://128.180.121.231:5010/repo'),
        headers: {'Content-Type': 'text/plain'},
        body: 'object',
      );
    } catch (e) {
      print('Error sending repo signal: $e');
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      print('No image captured.');
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
      filename: basename(pickedFile.path),
    ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBytes = await response.stream.toBytes();
        String responseText = String.fromCharCodes(responseBytes);

        setState(() {
          _resultText = responseText;
        });

        await _speak(responseText);
      } else {
        print('Upload failed with status: ${response.statusCode}');
        setState(() {
          _resultText = 'Upload failed: ${response.statusCode}';
        });
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
      appBar: AppBar(title: const Text('Kitchen Scan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Step 1: Take a photo of your vegetable drawer!', //remove this later and put in own page
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: captureAndSendImage,
              icon: const Icon(Icons.kitchen),
              label: const Text('Scan vegetables'),
            ),
            const SizedBox(height: 20),
            if (_imageFile != null) Image.file(_imageFile!, height: 200),
            const SizedBox(height: 20),
            Text(_resultText, style: const TextStyle(fontSize: 18)),

            const Text(
              'Step 2: Take a photo of your knife rack or utensils drawer!', //remove this later and put in own page
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: captureAndSendImage,
              icon: const Icon(Icons.kitchen),
              label: const Text('Scan Kitchen utensils'),
            ),
            const SizedBox(height: 20),
            if (_imageFile1 != null) Image.file(_imageFile1!, height: 200),
            const SizedBox(height: 20),
            Text(_resultText1, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
*/