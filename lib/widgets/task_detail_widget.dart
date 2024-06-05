import 'package:flutter/material.dart';
import 'package:task_manager/models/task_detail.dart';

class TaskDetailWidget extends StatelessWidget {
  final TaskDetail detail;

  const TaskDetailWidget({Key? key, required this.detail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(detail.title),
        subtitle: Text(detail.subtitle),
        leading: Icon(detail.icon),
        tileColor: Theme.of(context).focusColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
    );
  }
}
