import 'package:flutter/cupertino.dart';
import 'package:personal_expenses_tracker/about/about_screen.dart';
import 'package:personal_expenses_tracker/profile/profile_screen.dart';
import 'package:personal_expenses_tracker/summary/summary_screen.dart';

/// A `StatelessWidget` that is a `const` and has a `super.key` in its constructor
class HomeScreen extends StatefulWidget {
  /// A constructor that is `const` and has a `super.key` in its constructor.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_fill),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.info_circle_fill),
            label: 'Acerca de',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            if (index == 0) {
              return const SummaryScreen();
            }
            if (index == 1) {
              return const ProfileScreen();
            }
            if (index == 2) {
              return const AboutScreen();
            }

            return const SummaryScreen();
          },
        );
      },
    );
  }
}
