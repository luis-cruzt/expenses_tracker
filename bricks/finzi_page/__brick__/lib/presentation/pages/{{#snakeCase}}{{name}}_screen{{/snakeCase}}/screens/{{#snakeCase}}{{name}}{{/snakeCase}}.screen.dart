import 'package:flutter/material.dart';

/// The statelessWidget that handles the current screen
class {{#pascalCase}}{{name}} screen {{/pascalCase}} extends StatelessWidget {
  /// The constructor.
  const {{#pascalCase}}{{name}} screen {{/pascalCase}}({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: const [SizedBox()],
        ),
      ),
    );
  }
}
