import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:interassignment1/components/task_card.dart';
import 'package:interassignment1/models/task_model.dart';
import 'package:interassignment1/screens/login_screen.dart';
import 'package:interassignment1/screens/task_form_screen.dart';
import 'package:interassignment1/services/auth_service.dart';
import 'package:interassignment1/services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String selectedPriority = 'All';
  bool? showCompleted; // null means "All Tasks"
  User? user = AuthService().getCurrentUser();

  List<TaskModel> filterTasks(List<TaskModel> tasks) {
    final filtered =
        tasks.where((task) {
          if (selectedPriority != 'All' &&
              TaskModel.priorityToString(task.priority).toLowerCase() !=
                  selectedPriority.toLowerCase()) {
            return false;
          }

          if (showCompleted != null && task.isCompleted != showCompleted) {
            return false;
          }

          return true;
        }).toList();

    // Sort by due date (earliest to latest)
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return filtered;
  }

  void _editTask(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TaskFormScreen(
              initialTitle: task.title,
              initialDescription: task.description,
              initialPriority: task.priority,
              initialDueDate: task.dueDate,
              isEditMode: true,
              onSave: (TaskModel updatedTask) {
                // Create a new TaskModel with updated data while preserving the completion status
                final updatedTaskWithId = TaskModel(
                  id: task.id, // Preserve the ID
                  title: updatedTask.title,
                  description: updatedTask.description,
                  dueDate: updatedTask.dueDate,
                  priority: updatedTask.priority,
                  isCompleted:
                      task.isCompleted, // Preserve the completion status
                );

                TaskService().updateTask(updatedTaskWithId, user!.uid);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task updated successfully!')),
                );
              },
            ),
      ),
    );
  }

  void _toggleCompletion(TaskModel task) {
    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: !task.isCompleted,
    );

    TaskService().updateTask(updatedTask, user!.uid);
  }

  void _deleteTask(TaskModel task) {
    TaskService().deleteTask(task.id!, user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7F6),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text(
          'My Tasks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Priority Filter
          Tooltip(
            message: 'Filter by Priority',
            child: PopupMenuButton<String>(
              onSelected: (value) => setState(() => selectedPriority = value),
              icon: const Icon(Icons.filter_list, color: Colors.white),
              itemBuilder:
                  (_) => const [
                    PopupMenuItem(value: 'All', child: Text('All Priorities')),
                    PopupMenuItem(value: 'Low', child: Text('Low')),
                    PopupMenuItem(value: 'Medium', child: Text('Medium')),
                    PopupMenuItem(value: 'High', child: Text('High')),
                  ],
            ),
          ),

          // Completion Filter
          Tooltip(
            message: 'Filter by Completion',
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  if (value == 'All') {
                    showCompleted = null;
                  } else if (value == 'Completed') {
                    showCompleted = true;
                  } else if (value == 'Incomplete') {
                    showCompleted = false;
                  }
                  debugPrint("showCompleted set to: $showCompleted");
                });
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              itemBuilder:
                  (_) => const [
                    PopupMenuItem(value: 'All', child: Text('All Tasks')),
                    PopupMenuItem(
                      value: 'Incomplete',
                      child: Text('Incomplete'),
                    ),
                    PopupMenuItem(value: 'Completed', child: Text('Completed')),
                  ],
            ),
          ),

          // Logout
          Tooltip(
            message: 'Logout',
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                AuthService().signOut().then(
                  (_) => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService().getTasks(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found'));
          }

          final tasks = snapshot.data!;
          final filteredTasks = filterTasks(tasks);

          return filteredTasks.isEmpty
              ? const Center(child: Text("No tasks match your filter."))
              : ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (_, index) {
                  final task = filteredTasks[index];

                  return Dismissible(
                    key: Key(task.id ?? UniqueKey().toString()),
                    onDismissed: (_) {
                      _deleteTask(task);
                      debugPrint("Removed task");
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: TaskCard(
                      title: task.title,
                      description: task.description,
                      priority:
                          TaskModel.priorityToString(
                            task.priority,
                          ).toLowerCase(),
                      isDone: task.isCompleted,
                      dueDate: task.dueDate,
                      onEdit: () => _editTask(task),
                      onToggle: (_) => _toggleCompletion(task),
                    ),
                  );
                },
              );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: "Add Task",
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TaskFormScreen(
                    onSave: (TaskModel newTask) {
                      TaskService().createTask(newTask, user!.uid);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task added successfully!'),
                        ),
                      );
                    },
                  ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),
    );
  }
}
