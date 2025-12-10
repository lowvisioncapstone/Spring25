import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _p = TextEditingController();

  bool _showPwd = false;
  bool _loading = false;
  String? _error;

  late Dio dio;

  /// Backend base URL
  static const String baseUrl = 'http://128.180.121.231:5010';

  @override
  void initState() {
    super.initState();
    _initDio();
  }

  /// ✅ Configure Dio with persistent cookies
  Future<void> _initDio() async {
    final dir = await getApplicationDocumentsDirectory();

    final jar = PersistCookieJar(
      storage: FileStorage('${dir.path}/cookies'),
    );

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(CookieManager(jar));
  }

  /// Backend contract:
  /// POST /login
  /// Body: { username, password }
  /// Response:
  /// { ok: true, user: {...} }
  /// OR
  /// { ok: false, error: "message" }
  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resp = await dio.post(
        '/login',
        data: {
          'username': _u.text.trim(),
          'password': _p.text,
        },
      );

      final decoded = resp.data;

      if (decoded is! Map || decoded['ok'] != true) {
        final msg = decoded is Map && decoded['error'] != null
            ? decoded['error'].toString()
            : 'Invalid username or password';
        setState(() => _error = msg);
        return;
      }

      final user = decoded['user'];
      if (user == null) {
        setState(() => _error = 'Malformed server response');
        return;
      }

      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("username", _u.text);
      await prefs.setString("password", _p.text);

      Navigator.pushReplacementNamed(
        context,
        '/main',
        arguments: user,
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map && e.response?.data['error'] != null
          ? e.response!.data['error'].toString()
          : 'Network error: ${e.message}';
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _u.dispose();
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.5);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                color: Colors.black,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.orange, width: 3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 36 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _u,
                          style: const TextStyle(color: Colors.orange, fontSize: 24),
                          decoration: _inputDecoration(
                            'Username',
                            Icons.person_outline,
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Please enter username'
                                  : null,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _p,
                          obscureText: !_showPwd,
                          style: const TextStyle(color: Colors.orange, fontSize: 24),
                          decoration: _inputDecoration(
                            'Password',
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _showPwd
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.orange,
                              ),
                              onPressed: () =>
                                  setState(() => _showPwd = !_showPwd),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty)
                                  ? 'Please enter password'
                                  : null,
                          onFieldSubmitted: (_) => _login(),
                        ),

                        const SizedBox(height: 20),

                        if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.black,
                              textStyle: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.black,
                                  )
                                : const Text('Continue'),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'No account? Create one',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.orange,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.orange, fontSize: 22),
      prefixIcon: Icon(icon, color: Colors.orange),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.orange, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
