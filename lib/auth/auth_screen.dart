import 'package:flutter/material.dart';

/// A `StatelessWidget` that displays a `Scaffold` with an `AppBar` that has a title of `Login`
class AuthScreen extends StatelessWidget {
  /// A named constructor.
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const FlutterLogo(
              size: 150,
            ),
            Flexible(
              child: LoginButton(
                icon: Icons.person,
                text: 'Continue as Guest',
                loginMethod: () {},
                color: Colors.deepPurple,
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// This class is a stateless widget that takes in a color, icon, text, and a login method. It then
/// returns a container with an elevated button that has an icon, style, onPressed, and label
class LoginButton extends StatelessWidget {
  /// A named constructor that is taking in a key, text, icon, color, and loginMethod.
  const LoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.loginMethod,
  });

  /// A variable that is being passed in as a parameter.
  final Color color;

  /// A variable that is being passed in as a parameter.
  final IconData icon;

  /// A variable that is being passed in as a parameter.
  final String text;

  /// A function that is being passed in as a parameter.
  final Function loginMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(24),
          backgroundColor: color,
        ),
        onPressed: () => loginMethod(),
        label: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
