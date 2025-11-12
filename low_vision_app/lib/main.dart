import 'package:flutter/material.dart';
import 'menu_ocr_screen.dart';
import 'kitchen_instruction_page.dart';
import 'user_profile_screen.dart';
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
      title: 'Low Vision Daily Companion',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.orange,
          centerTitle: true,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 26, color: Colors.orange),
          bodyMedium: TextStyle(fontSize: 24, color: Colors.orange),
          labelLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            minimumSize: const Size(280, 90),
            side: const BorderSide(color: Colors.black, width: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/main': (_) => const MainScreen(),
        '/register': (_) => const RegisterPage(),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.5);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 160,
        title: Text(
          'Daily Vision \nCompanion',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
      body: const SafeArea(child: ButtonScreen()),
    );
  }
}

class ButtonScreen extends StatelessWidget {
  const ButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.5);
    final buttonSpacing = SizedBox(height: 30 * scale);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Semantics(
          label: 'Daily Vision \nCompanion',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AccessibleButton(
                label: 'Kitchen Assistant',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KitchenInstructionPage()),
                ),
              ),
              buttonSpacing,
              AccessibleButton(
                label: 'Menu Assistant',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuOCRScreen()),
                ),
              ),
              buttonSpacing,
              AccessibleButton(
                label: 'User Profile',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AccessibleButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
