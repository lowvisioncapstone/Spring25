import 'package:flutter/material.dart';
import 'menu_ocr_screen.dart';
import 'kitchen_scan_screen.dart';
import 'kitchen_instruction_page.dart';
import 'login_page.dart';
import 'register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/main' : (_) => const MainScreen(),
        '/register': (_) => const RegisterPage(),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 200,
        backgroundColor: const Color(0xFF99ccff),
        title: const Center(
          child: SizedBox(
            width: double.infinity,
            child: Text(
              'Low Vision Daily Companion',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF99ccff),
      body: const ButtonScreen(),
    );
  }
}

class ButtonScreen extends StatelessWidget {
  const ButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 250,
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KitchenInstructionPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 2),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  child: const Text('Kitchen Assistant'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MenuOCRScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 2),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  child: const Text('Menu Assistant'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
