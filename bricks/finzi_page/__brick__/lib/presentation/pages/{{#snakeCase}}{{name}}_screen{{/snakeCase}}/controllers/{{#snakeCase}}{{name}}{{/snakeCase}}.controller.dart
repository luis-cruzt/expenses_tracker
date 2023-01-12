import 'package:finzi/presentation/pages/{{#snakeCase}}{{name}}_screen{{/snakeCase}}/states/{{name}}.state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Creating a provider for the LoginScreenController.
final {{#lowerCase}}{{name}}ScreenProvider{{/lowerCase}} =
    StateNotifierProvider<{{#pascalCase}}{{name}} screen controller{{/pascalCase}}, {{#pascalCase}}{{name}} screen state {{/pascalCase}}>((ref) {
  return {{#pascalCase}}{{name}} screen controller{{/pascalCase}}(
    const {{#pascalCase}}{{name}} screen state {{/pascalCase}}(),
  );
});

/// Creating a provider for the class.
// final {{#pascalCase}}{{name}} repository {{/pascalCase}} = Provider<{{#pascalCase}}{{name}} remote impl {{/pascalCase}}>((ref) => {{#pascalCase}}{{name}} remote impl {{/pascalCase}}());

/// It's a state notifier that has a state of type LoginScreenState and it has methods to set the user
/// email, password, verification code, send the email to the user, log in the user, log out the user,
/// send user information, check user sons and validate the given code

class {{#pascalCase}}{{name}} screen controller{{/pascalCase}} extends StateNotifier<{{#pascalCase}}{{name}} screen state {{/pascalCase}}> {
  /// Constructor
  {{#pascalCase}}{{name}} screen controller{{/pascalCase}}({{#pascalCase}}{{name}} screen state {{/pascalCase}} state) : super(state);

}
