import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/misc/local_notifications.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/dialogs/add_task_dialog.dart';
import 'package:task_manager/dialogs/edit_task_dialog.dart';
import 'package:task_manager/screens/profile.dart';
import 'package:task_manager/screens/settings.dart';
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
    Provider.of<TaskProvider>(context, listen: false).fetchTasks();
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

    User user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tasks",
        ),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case "Profile":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => Profile(
                        user: user,
                      ),
                    ),
                  );
                  break;
                case "Settings":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const SettingsScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline_sharp),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (taskProvider.tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks found.',
              ),
            );
          }

          return ListView.builder(
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
