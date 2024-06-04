import 'package:flutter/material.dart';

class TaskDetails extends StatelessWidget {
  final String payload;
  const TaskDetails({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
      ),
      body: Center(
        child: Column(
          children: [
            const Text("Payload:"),
            Text(payload),
          ],
        ),
      ),
    );
  }
}
