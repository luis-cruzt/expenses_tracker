import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:personal_expenses_tracker/auth/auth_service.dart';

/// A `StatelessWidget` that displays a `Scaffold` with an `AppBar` that has a title of `Login`
class AuthScreen extends StatelessWidget {
  /// A named constructor.
  const AuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(
            child: WhatsNewPage(
              title: const Text('Control de gastos'),
              features: [
                // Feature's type must be `WhatsNewFeature`
                WhatsNewFeature(
                  icon: Icon(
                    CupertinoIcons.mail,
                    color: CupertinoColors.systemBlue.resolveFrom(context),
                  ),
                  title: const Text('Control'),
                  description: const Text(
                    'Lleva un control diario de todos los gastos que realizas en tu día a día.',
                  ),
                ),
                WhatsNewFeature(
                  icon: Icon(
                    CupertinoIcons.time,
                    color: CupertinoColors.systemBlue.resolveFrom(context),
                  ),
                  title: const Text('Recordatorios'),
                  description: const Text(
                    'La aplicación te recordará a final del día de registrar los gastos que llevas, para que en ningún momento se te olvidé anotar los gastos.',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                child: const Text('Continuar como invitado'),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: AuthService().googleLogin,
                  child: Text(
                    'Continuar con Google',
                    style: CupertinoTheme.of(context).textTheme.textStyle.merge(
                          const TextStyle(
                            color: CupertinoColors.white,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       padding: const EdgeInsets.all(20),
  //       child: Column(
  //         children: [
  //           const Spacer(),
  //           const Text(
  //             'Expenses Tracker',
  //             style: TextStyle(
  //               fontSize: 32,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const Spacer(),
  //           LoginButton(
  //             text: 'Continuar anónimo',
  //             loginMethod: () {},
  //           ),
  //           LoginButton(
  //             text: 'Sign in with Google',
  //             loginMethod: AuthService().googleLogin,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

/// This class is a stateless widget that takes in a color, icon, text, and a login method. It then
/// returns a container with an elevated button that has an icon, style, onPressed, and label
class LoginButton extends StatelessWidget {
  /// A named constructor that is taking in a key, text, icon, color, and loginMethod.
  const LoginButton({
    super.key,
    required this.text,
    required this.loginMethod,
  });

  /// A variable that is being passed in as a parameter.
  final String text;

  /// A function that is being passed in as a parameter.
  final Function loginMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      child: CupertinoButton.filled(
        child: Text(text, textAlign: TextAlign.center),
        onPressed: () => loginMethod(),
      ),
      // ElevatedButton.icon(
      //   icon: Icon(
      //     icon,
      //     color: Colors.white,
      //     size: 20,
      //   ),
      //   style: TextButton.styleFrom(
      //     padding: const EdgeInsets.all(24),
      //     backgroundColor: color,
      //   ),
      //   onPressed: () => loginMethod(),
      //   label: ,
      // ),
    );
  }
}
