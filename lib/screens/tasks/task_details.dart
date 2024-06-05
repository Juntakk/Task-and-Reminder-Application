import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/models/task_detail.dart';
import 'package:task_manager/widgets/task_detail_widget.dart';

class TaskDetails extends StatelessWidget {
  const TaskDetails({super.key, required this.task});

  final QueryDocumentSnapshot? task;

  @override
  Widget build(BuildContext context) {
    final List<TaskDetail> details = [
      TaskDetail(
        title: "Task",
        subtitle: task?["title"].toString() ?? "No title",
        icon: Icons.task_alt_sharp,
      ),
      TaskDetail(
        title: "Description",
        subtitle: task?["description"].toString() ?? "No description",
        icon: Icons.description_outlined,
      ),
      TaskDetail(
        title: "Priority",
        subtitle: task?["priority"].toString() ?? "No priority",
        icon: Icons.label_important_outline_sharp,
      ),
      TaskDetail(
        title: "Due Date",
        subtitle: task?["dueDate"] != null
            ? DateFormat.yMd().format(task!["dueDate"].toDate())
            : "No due date",
        icon: Icons.timer,
      ),
      TaskDetail(
        title: "Reminder Date",
        subtitle: task?["reminder"] != null
            ? DateFormat.yMd().format(task!["reminder_start_date"].toDate())
            : "No reminder set",
        icon: Icons.date_range_outlined,
      ),
      TaskDetail(
        title: "Reminder Frequency",
        subtitle: task?["reminder"]?.toString() ?? "No reminder set",
        icon: Icons.multiple_stop_sharp,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: details.length,
          itemBuilder: (context, index) {
            return TaskDetailWidget(detail: details[index]);
          },
        ),
      ),
    );
  }
}
