import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTask(TaskModel task, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .add(task.toMap());
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Stream<List<TaskModel>> getTasks(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(),id: doc.id))
              .toList());
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  Future<void> updateTask(TaskModel task, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String taskId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}