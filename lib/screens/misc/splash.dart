import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/screens/auth/auth.dart';
import 'package:task_manager/screens/misc/load.dart';
import 'package:task_manager/screens/tasks/tasks.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({Key? key}) : super(key: key);

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const AuthCheck()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('lib/assets/chat.png'),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
    );
  }
}
