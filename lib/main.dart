import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:personal_expenses_tracker/auth/auth_screen.dart';
import 'package:personal_expenses_tracker/auth/auth_service.dart';
import 'package:personal_expenses_tracker/firebase_options.dart';
import 'package:personal_expenses_tracker/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'expenses_reminder',
        channelKey: 'expenses_daily',
        channelName: 'Daily Expenses Channel',
        channelDescription: 'Daily reminders for the user',
      )
    ],
    debug: true,
  );
  final allowed = await AwesomeNotifications().isNotificationAllowed();
  if (!allowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  } else {
    final localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'expenses_daily',
        title: '¿Ya registraste tus gastos?',
        body: 'No se te olvide registrar los gastos del día de hoy.',
      ),
      schedule: NotificationCalendar(
        hour: 21,
        minute: 30,
        second: 0,
        allowWhileIdle: true,
        repeats: true,
        timeZone: localTimeZone,
      ),
    );
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/// `MyApp` is a `StatelessWidget` that returns a `ProviderScope` widget that contains a `CupertinoApp`
/// widget that has a `title` and a `home` property
class MyApp extends StatelessWidget {
  /// A named constructor that is calling the super class's constructor.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: GlobalLoaderOverlay(
        useDefaultLoading: false,
        overlayWidget: CupertinoApp(
          debugShowCheckedModeBanner: false,
          home: CupertinoAlertDialog(
            title: Text(
              'Cargando',
              style: CupertinoTheme.of(context).textTheme.textStyle.merge(
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CupertinoActivityIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Espera un momento...',
                  style: CupertinoTheme.of(context).textTheme.textStyle.merge(
                        const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
        child: const CupertinoApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            DefaultCupertinoLocalizations.delegate,
          ],
          home: AuthenticationWrapper(),
        ),
      ),
    );
  }
}

/// `AuthenticationWrapper` is a `ConsumerWidget` that listens to the `AuthService`'s `userStream` and
/// displays either the `AuthScreen` or the `HomeScreen` depending on the stream's state
class AuthenticationWrapper extends ConsumerWidget {
  /// A named constructor that is calling the super class's constructor.
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            'Loading',
            style: CupertinoTheme.of(context).textTheme.textStyle.merge(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error',
            style: CupertinoTheme.of(context).textTheme.textStyle.merge(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
          );
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
