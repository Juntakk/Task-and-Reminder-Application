import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/firebase_options.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/auth.dart';
import 'package:task_manager/screens/splash.dart';
import 'package:task_manager/screens/tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
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
          appBarTheme: AppBarTheme(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
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
