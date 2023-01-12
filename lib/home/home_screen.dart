import 'package:flutter/material.dart';

/// A `StatelessWidget` that is a `const` and has a `super.key` in its constructor
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Home Screen'),
    );
  }
}
