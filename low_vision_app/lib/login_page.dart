import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  static const String baseUrl = 'http://128.180.121.231:5010'; // Replace with real IP later

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _u.text.trim(), 'password': _p.text}),
      );
      if (resp.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        final msg = (jsonDecode(resp.body)['error'] ?? 'Login failed') as String;
        setState(() => _error = msg);
      }
    } catch (e) {
      setState(() => _error = 'Network error: $e');
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Semantics(
                label: 'Login Page',
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
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Username
                          Semantics(
                            label: 'Username input field',
                            child: TextFormField(
                              controller: _u,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 24,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 22,
                                ),
                                prefixIcon:
                                    const Icon(Icons.person_outline, color: Colors.orange),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.orange, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.orange, width: 3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter username'
                                  : null,
                              textInputAction: TextInputAction.next,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Password
                          Semantics(
                            label: 'Password input field',
                            child: TextFormField(
                              controller: _p,
                              obscureText: !_showPwd,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 24,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 22,
                                ),
                                prefixIcon:
                                    const Icon(Icons.lock_outline, color: Colors.orange),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _showPwd = !_showPwd),
                                  icon: Icon(
                                    _showPwd
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.orange,
                                  ),
                                  tooltip: _showPwd
                                      ? 'Hide password'
                                      : 'Show password',
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.orange, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.orange, width: 3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Please enter password'
                                  : null,
                              onFieldSubmitted: (_) => _login(),
                            ),
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

                          // Continue button
                          Semantics(
                            button: true,
                            label: 'Continue button',
                            child: SizedBox(
                              width: double.infinity,
                              height: 70,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                        color: Colors.orange, width: 3),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: _loading ? null : _login,
                                child: _loading
                                    ? const SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text('Continue'),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Register link
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
      ),
    );
  }
}
