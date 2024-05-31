import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _tasks = [];

  List<DocumentSnapshot> get tasks => _tasks;

  Future<void> fetchTasks() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .get();
      _tasks = querySnapshot.docs;
      notifyListeners();
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> newData) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update(newData);
      notifyListeners();
    } catch (e) {
      //error message
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      //error message
    }
  }

  Future<void> addTask(String title, String description, DateTime dueDate,
      String priority) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('tasks').add({
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'priority': priority,
        'userId': user.uid, // Associate task with the user
      });
      notifyListeners();
    }
  }
}
