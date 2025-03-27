import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 200, //vertical spacing for title
          backgroundColor: Color(0xFF99ccff),
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
        backgroundColor: Color(0xFF99ccff), //set background color
        body: const ButtonScreen(),
      ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Kitchen Assistant Pressed')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.black, width: 2), //black border
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menu Assistant Pressed')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.black, width: 2), //black border
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
