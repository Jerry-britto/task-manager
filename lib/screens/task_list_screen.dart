import 'package:flutter/material.dart';
import 'package:interassignment1/components/task_card.dart';
import 'package:interassignment1/models/task_model.dart';
import 'package:interassignment1/screens/task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String selectedPriority = 'All';
  bool? showCompleted; // null means "All Tasks"

  final List<TaskModel> tasks = [
    TaskModel(
      title: 'Buy groceries',
      description: 'Milk, eggs, and bread',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: Priority.high,
      isCompleted: true,
    ),
    TaskModel(
      title: 'Walk the dog',
      description: 'Evening walk around the park',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: Priority.low,
      isCompleted: false,
    ),
    TaskModel(
      title: 'Finish project',
      description: 'Submit the final report',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: Priority.medium,
      isCompleted: false,
    ),
    TaskModel(
      title: 'Call John',
      description: 'Discuss weekend plans',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      priority: Priority.high,
      isCompleted: true,
    ),
  ];

  List<TaskModel> get filteredTasks {
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

  void _editTask(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TaskFormScreen(
              initialTitle: tasks[index].title,
              initialDescription: tasks[index].description,
              initialPriority: tasks[index].priority,
              initialDueDate: tasks[index].dueDate,
              isEditMode: true,
              onSave: (TaskModel updatedTask) {
                setState(() {
                  // Create a new TaskModel with updated data while preserving the completion status
                  tasks[index] = TaskModel(
                    title: updatedTask.title,
                    description: updatedTask.description,
                    dueDate: updatedTask.dueDate,
                    priority: updatedTask.priority,
                    isCompleted:
                        tasks[index]
                            .isCompleted, // Preserve the completion status
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task updated successfully!')),
                );
              },
            ),
      ),
    );
  }

  void _toggleCompletion(int index) {
    setState(() {
      tasks[index] = TaskModel(
        title: tasks[index].title,
        description: tasks[index].description,
        dueDate: tasks[index].dueDate,
        priority: tasks[index].priority,
        isCompleted: !tasks[index].isCompleted,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
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
              onPressed: () => debugPrint('User logged out'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          filteredTasks.isEmpty
              ? const Center(child: Text("No tasks match your filter."))
              : ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (_, index) {
                  final task = filteredTasks[index];
                  final originalIndex = tasks.indexOf(task);

                  return Dismissible(
                    key: Key(task.title),
                    onDismissed: (_) {
                      setState(() => tasks.removeAt(originalIndex));
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
                      onEdit: () => _editTask(originalIndex),
                      onToggle: (_) => _toggleCompletion(originalIndex),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: "Add Task",
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TaskFormScreen(
                    onSave: (TaskModel newTask) {
                      setState(() {
                        tasks.add(newTask);
                      });
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
