import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot> _tasks = [];

  List<QueryDocumentSnapshot> get tasks => _tasks;

  Future<void> fetchTasks() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .get();
      _tasks = querySnapshot.docs;
      notifyListeners();
    }
  }

  Future<void> addTask(Map<String, dynamic> taskData) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('tasks').add({
        ...taskData,
        'userId': user.uid,
      });
      await fetchTasks();
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    await _firestore.collection('tasks').doc(taskId).update(taskData);
    await fetchTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
    await fetchTasks();
  }
}
