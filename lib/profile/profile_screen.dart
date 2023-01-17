import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:personal_expenses_tracker/auth/auth_service.dart';

/// It's a stateless widget that displays a button that, when pressed, signs out the user and navigates
/// to the login screen
class ProfileScreen extends StatelessWidget {
  /// It's a constructor that calls the superclass constructor with the given key.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AuthService().user?.displayName ?? 'Sin nombre',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            const SizedBox(height: 10),
            Text(
              AuthService().user?.email ?? 'Sin correo',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                FlutterClipboard.copy(AuthService().user?.uid ?? 'Oops')
                    .then((value) {
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) => CupertinoAlertDialog(
                      title: const Text('¡Listo!'),
                      content: const Text('ID copiado a la papelera'),
                      actions: <CupertinoDialogAction>[
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Ok'),
                        ),
                      ],
                    ),
                  );
                });
              },
              child: Text(
                AuthService().user?.uid ?? 'Sin id',
                style: CupertinoTheme.of(context).textTheme.textStyle.merge(
                      const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                child: const Text('Cerrar sesión'),
                onPressed: () {
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) => CupertinoAlertDialog(
                      title: const Text('Confirmación'),
                      content: const Text('¿Estás seguro de cerrar sesión?'),
                      actions: <CupertinoDialogAction>[
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('No'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () async {
                            await AuthService().signOut();
                            unawaited(
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/',
                                (route) => false,
                              ),
                            );
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
