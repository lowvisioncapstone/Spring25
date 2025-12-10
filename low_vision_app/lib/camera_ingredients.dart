import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

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

  late Dio dio;
  final String baseUrl = 'http://128.180.121.231:5010';

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


  @override
  void initState() {
    super.initState();
    _setupDio();
    // Open camera automatically after a short delay
      Future.delayed(Duration(milliseconds: 300), captureAndSendImage);
    }

    Future<void> captureAndSendImage() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.camera);

  if (pickedFile == null) {
    Navigator.pop(this.context);
    return;
  }

  setState(() {
    _imageFile = File(pickedFile.path);
    _resultText = 'Processing...';
  });

  // Send repo signal
  try {
    await dio.post(
      '/repo',
      data: 'object',
      options: Options(contentType: Headers.textPlainContentType),
    );
  } catch (e) {
    print('Error sending repo signal: $e');
  }

  // Upload image
  try {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        pickedFile.path,
        filename: p.basename(pickedFile.path),
      ),
      'ingredients': widget.ingredientList.isNotEmpty
          ? widget.ingredientList.join('\n')
          : '',
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


  

    // final uri = Uri.parse(apiUrl);
    // final request = http.MultipartRequest('POST', uri);
    // request.files.add(await http.MultipartFile.fromPath(
    //   'image',
    //   pickedFile.path,
    //   filename: p.basename(pickedFile.path),
    // ));

    // request.fields['ingredients'] = widget.ingredientList.join('\n');

    // try {
    //   final response = await request.send();
    //   if (response.statusCode == 200) {
    //     final responseBytes = await response.stream.toBytes();
    //     final responseText = String.fromCharCodes(responseBytes);

    //     setState(() => _resultText = responseText);
    //     await _speak(responseText);
    //   } else {
    //     setState(() => _resultText = 'Upload failed: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   setState(() => _resultText = 'Error uploading image: $e');
    // }
  // }

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
      child: SingleChildScrollView( // <-- make it scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              style: const TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
    ),
  );
}

}