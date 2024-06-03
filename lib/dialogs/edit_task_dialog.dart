import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/providers/task_provider.dart';

void showEditTaskDialog(BuildContext context, QueryDocumentSnapshot task) {
  final titleController = TextEditingController(text: task['title']);
  final descriptionController =
      TextEditingController(text: task['description']);
  DateTime? dueDate =
      task['dueDate'] != null ? (task['dueDate'] as Timestamp).toDate() : null;
  String? priority = task['priority'];
  bool setReminder = task['reminder'] != null;
  String? reminderFrequency = task['reminder'];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(21),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Edit Task'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text(dueDate == null
                          ? 'Select Due Date'
                          : 'Due Date: ${DateFormat.yMd().format(dueDate!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dueDate = pickedDate;
                          });
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ['High', 'Medium', 'Low']
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          priority = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Set Reminder'),
                      value: setReminder,
                      onChanged: (value) {
                        setState(() {
                          setReminder = value;
                          if (!setReminder) {
                            reminderFrequency = null;
                          }
                        });
                      },
                    ),
                    if (setReminder)
                      DropdownButtonFormField<String>(
                        value: reminderFrequency,
                        decoration: const InputDecoration(
                            labelText: 'Reminder Frequency'),
                        items: ['Daily', 'Weekly', 'Monthly']
                            .map((frequency) => DropdownMenuItem(
                                  value: frequency,
                                  child: Text(frequency),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            reminderFrequency = value;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final taskData = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'dueDate':
                        dueDate != null ? Timestamp.fromDate(dueDate!) : null,
                    'priority': priority,
                    if (setReminder) 'reminder': reminderFrequency,
                  };
                  Provider.of<TaskProvider>(context, listen: false)
                      .updateTask(task.id, taskData);
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
