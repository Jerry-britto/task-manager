import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

final taskListProvider = StateNotifierProvider<TaskListNotifier, List<TaskModel>>((ref) {
  final taskService = ref.read(taskServiceProvider);
  return TaskListNotifier(taskService);
});

class TaskListNotifier extends StateNotifier<List<TaskModel>> {
  final TaskService _taskService;

  TaskListNotifier(this._taskService) : super([]) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      state = await _taskService.getTasks();
    } catch (e) {
      // Handle error appropriately, e.g., log it or show a message
      print('Error fetching tasks: $e');
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      final taskId = await _taskService.createTask(task);
      state = [...state, task.copyWith(id: taskId)];
    } catch (e) {
      // Handle error
      print('Error adding task: $e');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _taskService.updateTask(task);
      state = state.map((t) => t.id == task.id ? task : t).toList();
    } catch (e) {
      // Handle error
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      state = state.where((t) => t.id != taskId).toList();
    } catch (e) {
      // Handle error
      print('Error deleting task: $e');
    }
  }
}