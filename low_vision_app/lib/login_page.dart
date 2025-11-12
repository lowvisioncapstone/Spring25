// lib/login_page.dart
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

  static const String baseUrl = 'http://10.0.2.2:5010';//Need to change this to real IP address

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
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
  void dispose() { _u.dispose(); _p.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Sign in', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _u,
                    decoration: const InputDecoration(
                      labelText: 'Username', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v==null || v.trim().isEmpty) ? 'Please enter username' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _p,
                    obscureText: !_showPwd,
                    decoration: InputDecoration(
                      labelText: 'Password', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: ()=> setState(()=> _showPwd = !_showPwd),
                        icon: Icon(_showPwd ? Icons.visibility_off : Icons.visibility),
                      ),
                    ),
                    validator: (v) => (v==null || v.isEmpty) ? 'Please enter password' : null,
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 8),
                  if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('No account? Create one'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
