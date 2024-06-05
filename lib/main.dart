import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/misc/firebase_options.dart';
import 'package:task_manager/misc/local_notifications.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/auth/auth.dart';
import 'package:task_manager/screens/misc/load.dart';
import 'package:task_manager/screens/misc/splash.dart';
import 'package:task_manager/screens/tasks/tasks.dart';
import 'package:task_manager/screens/misc/settings.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await LocalNotifications.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: App(savedThemeMode: savedThemeMode),
    ),
  );
}

class App extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const App({Key? key, this.savedThemeMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        primarySwatch: Colors.amber,
        brightness: Brightness.light,
      ),
      dark: ThemeData(
        primarySwatch: Colors.amber,
        brightness: Brightness.dark,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Task and Reminder Application',
        theme: theme,
        darkTheme: darkTheme,
        home: const CustomSplashScreen(),
      ),
    );
  }
}
