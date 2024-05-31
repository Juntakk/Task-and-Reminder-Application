import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/add_task.dart';
import 'package:task_manager/screens/edit_task.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          taskProvider.fetchTasks();

          if (taskProvider.tasks.isEmpty) {
            return const Center(
              child: Text('No tasks'),
            );
          } else {
            return ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                var task =
                    taskProvider.tasks[index].data() as Map<String, dynamic>;
                return Dismissible(
                  key: Key(taskProvider.tasks[index].id),
                  onDismissed: (direction) {
                    taskProvider.deleteTask(taskProvider.tasks[index].id);
                  },
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: const Color.fromARGB(255, 169, 28, 18),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(task['title'] ?? 'No Title'),
                    subtitle: Text(task['description'] ?? 'No Description'),
                    trailing: Text(
                      task['priority'] ?? 'No Priority',
                    ),
                    onTap: () {
                      String taskId = taskProvider.tasks[index].id;
                      Map<String, dynamic> taskData = taskProvider.tasks[index]
                          .data() as Map<String, dynamic>;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => EditTaskScreen(
                              taskId: taskId, taskData: taskData),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
