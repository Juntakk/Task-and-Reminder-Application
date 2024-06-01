import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/providers/task_provider.dart';

void showAddTaskDialog(BuildContext context) {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? dueDate;
  String? priority;
  bool setReminder = false;
  String? reminderFrequency;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              ListTile(
                title: Text(dueDate == null
                    ? 'Select Due Date'
                    : 'Due Date: ${DateFormat.yMd().format(dueDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    dueDate = pickedDate;
                  }
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['High', 'Medium', 'Low']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) {
                  priority = value;
                },
              ),
              SwitchListTile(
                title: const Text('Set Reminder'),
                value: setReminder,
                onChanged: (value) {
                  setReminder = value;
                  (context as Element).markNeedsBuild();
                },
              ),
              if (setReminder)
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Reminder Frequency'),
                  items: ['Daily', 'Weekly', 'Monthly']
                      .map((frequency) => DropdownMenuItem(
                            value: frequency,
                            child: Text(frequency),
                          ))
                      .toList(),
                  onChanged: (value) {
                    reminderFrequency = value;
                  },
                ),
            ],
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
                'reminder': setReminder ? reminderFrequency : null,
              };
              Provider.of<TaskProvider>(context, listen: false)
                  .addTask(taskData);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
