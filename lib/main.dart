import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/firebase_options.dart';
import 'package:task_manager/local_notifications.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/auth.dart';
import 'package:task_manager/screens/load.dart';
import 'package:task_manager/screens/tasks.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await LocalNotifications.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'FlutterChat',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadScreen();
            }
            if (snapshot.hasData) {
              return const TasksScreen();
            }

            return const AuthScreen();
          },
        ),
      ),
    );
  }
}
