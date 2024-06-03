import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/local_notifications.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/dialogs/add_task_dialog.dart';
import 'package:task_manager/dialogs/edit_task_dialog.dart';
import 'package:task_manager/screens/task_details.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
  }

  //Listen to any notification click
  listenToNotifications() {
    LocalNotifications.onClickNotification.stream.listen(
      (event) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetails(payload: event),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: Colors.amber[800],
      appBar: AppBar(
        title: const Text(
          "Tasks",
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: taskProvider.fetchTasks(),
        builder: (context, snapshot) {
          Widget content;

          if (taskProvider.tasks.isEmpty) {
            content = const Center(
              child: Text(
                'No tasks found.',
              ),
            );
          } else {
            content = ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                return ListTile(
                  title: Text(task['title']),
                  subtitle: Text(task['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showEditTaskDialog(context, task);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          taskProvider.deleteTask(task.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return content;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
