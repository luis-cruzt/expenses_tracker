import 'dart:async';

import 'package:flutter/material.dart';
import 'package:personal_expenses_tracker/auth/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ElevatedButton(
        child: const Text('signout'),
        onPressed: () async {
          await AuthService().signOut();
          unawaited(
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false),
          );
        },
      ),
    );
  }
}
