import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _p = TextEditingController();
  final _p2 = TextEditingController();
  bool _showPwd = false;
  bool _loading = false;
  String? _error;

  static const String baseUrl = 'http://10.0.2.2:5010';

  Future<void> _doRegister() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _u.text.trim(), 'password': _p.text}),
      );
      if (resp.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered. Please sign in.'))
        );
      } else {
        final msg = (jsonDecode(resp.body)['error'] ?? 'Register failed') as String;
        setState(() => _error = msg);
      }
    } catch (e) {
      setState(() => _error = 'Network error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _u.dispose(); _p.dispose(); _p2.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _u,
                  decoration: const InputDecoration(
                    labelText: 'Username', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v==null || v.trim().isEmpty) ? 'Please enter username' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _p,
                  obscureText: !_showPwd,
                  decoration: InputDecoration(
                    labelText: 'Password', border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: ()=> setState(()=> _showPwd = !_showPwd),
                      icon: Icon(_showPwd ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  validator: (v) => (v==null || v.length<6) ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _p2,
                  obscureText: !_showPwd,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password', border: OutlineInputBorder()),
                  validator: (v) => (v != _p.text) ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 8),
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _doRegister,
                    child: _loading
                      ? const SizedBox(width:18,height:18,child: CircularProgressIndicator(strokeWidth:2))
                      : const Text('Create account'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
