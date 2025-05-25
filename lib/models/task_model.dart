import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

class TaskModel {
  final String? id; 
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;

  TaskModel({
    this.id, 
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  static String priorityToString(Priority priority) {
    return priority.toString().split('.').last;
  }

  static Priority priorityFromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        return Priority.low;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priorityToString(priority),
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TaskModel(
      id: id, 
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      priority: priorityFromString(map['priority']),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
