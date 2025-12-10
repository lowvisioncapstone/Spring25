import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

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

  late Dio dio;
  final String baseUrl = 'http://128.180.121.231:5010';

  @override
  void initState() {
    super.initState();
    _setupDio();
    Future.delayed(const Duration(milliseconds: 300), captureAndSendImage);
  }

  Future<void> _setupDio() async {
    final dir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(storage: FileStorage('${dir.path}/cookies'));

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<void> captureAndSendImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      Navigator.pop(this.context);
      return;
    }

    setState(() {
      _imageFile = File(pickedFile.path);
      _resultText = "Analyzing...";
    });

    // Send repo signal
    try {
      await dio.post(
        '/repo',
        data: 'boil',
        options: Options(contentType: Headers.textPlainContentType),
      );
    } catch (e) {
      print('Error sending repo signal: $e');
    }

    // Upload image using Dio + FormData
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          pickedFile.path,
          filename: basename(pickedFile.path),
        ),
      });

      final response = await dio.post('/upload', data: formData);

      if (response.statusCode == 200) {
        setState(() => _resultText = response.data.toString());
        await _speak(_resultText);
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
      appBar: AppBar(
        title: const Text("Boil Detector"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView( // <-- Added scrolling
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: captureAndSendImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Retake Photo"),
            ),
            const SizedBox(height: 20),
            if (_imageFile != null) Image.file(_imageFile!, height: 250),
            const SizedBox(height: 20),
            Text(
              _resultText,
              style: const TextStyle(fontSize: 40), // larger text
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
