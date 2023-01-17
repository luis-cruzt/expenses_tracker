import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';

/// A variable that is being used to store the value of the `context` parameter.
class AboutScreen extends StatelessWidget {
  /// A constructor.
  const AboutScreen({super.key});

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
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
