import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/misc/local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void showAddTaskDialog(BuildContext context) {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? dueDate;
  DateTime? reminderStartDate;
  String? priority;
  bool setReminder = false;
  String? reminderFrequency;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(21),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Add Task'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 300,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field cannot be empty';
                          } else if (value.length <= 1) {
                            return 'Must be more than 1 characters';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field cannot be empty';
                          } else if (value.length <= 6) {
                            return 'Must be more than 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        children: [
                          Text(
                            "Date",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text(dueDate == null
                            ? 'Select Due Date'
                            : DateFormat.yMd().format(dueDate!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
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
                        decoration:
                            const InputDecoration(labelText: 'Priority'),
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
                        validator: (value) {
                          if (value == null) {
                            return "Please select an option";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SwitchListTile(
                        title: const Text('Set Reminder'),
                        value: setReminder,
                        onChanged: (value) {
                          setState(() {
                            setReminder = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (setReminder)
                        const Row(
                          children: [
                            Text(
                              "Reminder date",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      if (setReminder)
                        ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: Text(
                            reminderStartDate == null
                                ? 'Select reminder date'
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
                          validator: (value) {
                            if (value == null) {
                              return "Please select an option";
                            }
                            return null;
                          },
                        ),
                    ],
                  ),
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
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (dueDate == null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Missing Due Date'),
                            content: const Text('Please select a due date.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    if (setReminder && reminderStartDate == null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Missing Reminder Date'),
                            content:
                                const Text('Please select a reminder date.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }
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
                        LocalNotifications.showScheduleNotification(
                          id: notificationId,
                          title: taskData['title'].toString(),
                          body: taskData['description'].toString(),
                          payload: '',
                          scheduledDate: nextReminderDate as tz.TZDateTime,
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
                        .addTask(taskData);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
