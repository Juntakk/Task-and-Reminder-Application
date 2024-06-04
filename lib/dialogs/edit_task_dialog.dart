import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/misc/local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void showEditTaskDialog(BuildContext context, QueryDocumentSnapshot task) {
  final titleController = TextEditingController(text: task['title']);
  final descriptionController =
      TextEditingController(text: task['description']);
  DateTime? dueDate =
      task['dueDate'] != null ? (task['dueDate'] as Timestamp).toDate() : null;
  String? priority = task['priority'];
  bool setReminder = task['reminder'] != null;
  String? reminderFrequency = task['reminder'];
  DateTime? reminderStartDate = task['reminder_start_date'] != null
      ? (task['reminder_start_date'] as Timestamp).toDate()
      : null;

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
                      title: Text(
                        dueDate == null
                            ? 'Select Due Date'
                            : DateFormat.yMd().format(dueDate!),
                      ),
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
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(
                          () {
                            priority = value;
                          },
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Set Reminder'),
                      value: setReminder,
                      onChanged: (value) {
                        setState(
                          () {
                            setReminder = value;
                            if (!setReminder) {
                              reminderFrequency = null;
                            }
                          },
                        );
                      },
                    ),
                    if (setReminder)
                      ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text(
                          reminderStartDate == null
                              ? 'Select Reminder Start Date'
                              : DateFormat.yMd().format(reminderStartDate!),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final pickedReminderDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedReminderDate != null) {
                            setState(() {
                              reminderStartDate = pickedReminderDate;
                            });
                          }
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
                          setState(
                            () {
                              reminderFrequency = value;
                            },
                          );
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
                    'reminder_start_date':
                        setReminder ? reminderStartDate : null,
                    'reminder': setReminder ? reminderFrequency : null,
                  };
                  // Generate a unique notification ID
                  final int notificationId =
                      DateTime.now().millisecondsSinceEpoch.remainder(100000);

                  // Calculate the scheduled date based on reminder frequency
                  DateTime? nextReminderDate;
                  if (setReminder &&
                      reminderStartDate != null &&
                      reminderFrequency != null) {
                    nextReminderDate = reminderStartDate;
                    while (nextReminderDate!.isBefore(dueDate!)) {
                      final scheduledDate = tz.TZDateTime.now(tz.local)
                          .add(const Duration(seconds: 10));

                      LocalNotifications.showScheduleNotification(
                        id: notificationId,
                        title: taskData['title'].toString(),
                        body: taskData['description'].toString(),
                        payload: '',
                        scheduledDate: scheduledDate,
                      );

                      // Update nextReminderDate based on frequency
                      switch (reminderFrequency) {
                        case 'Daily':
                          nextReminderDate =
                              nextReminderDate.add(const Duration(days: 1));
                          break;
                        case 'Weekly':
                          nextReminderDate =
                              nextReminderDate.add(const Duration(days: 7));
                          break;
                        case 'Monthly':
                          nextReminderDate = DateTime(
                            nextReminderDate.year,
                            nextReminderDate.month + 1,
                            nextReminderDate.day,
                          );
                          break;
                      }
                    }
                  }
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
