import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interassignment1/components/task_card.dart';
import 'package:interassignment1/models/task_model.dart';
import 'package:interassignment1/providers/auth_provider.dart';
import 'package:interassignment1/providers/task_list_provider.dart';
import 'package:interassignment1/screens/task_form_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskListProvider.notifier).fetchTasks();
    });
              TaskModel.priorityToString(task.priority).toLowerCase() !=
                  selectedPriority.toLowerCase() {
            return false;
          }

          if (showCompleted != null && task.isCompleted != showCompleted) {
            return false;
          }

          return true;
        }.toList();

    // Sort by due date (earliest to latest)
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Update the task list provider with the filtered list
    Future.microtask(() {
      ref.read(taskListProvider.notifier).setFilteredTasks(filtered);
    });
  }

  void _editTask(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(
          initialTitle: task.title,
          initialDescription: task.description,
          initialPriority: task.priority,
          initialDueDate: task.dueDate,
          isEditMode: true,
          onSave: (TaskModel updatedTask) {
            final updatedTaskModel = TaskModel(
              id: task.id,
              title: updatedTask.title,
              description: updatedTask.description,
              dueDate: updatedTask.dueDate,
              priority: updatedTask.priority,
              isCompleted: task.isCompleted,
            );
            ref
                .read(taskListProvider.notifier)
                .updateTask(updatedTaskModel)
                .then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task updated successfully!')),
              );
            });
          },
        ),
      ),
    );
  }

  void _toggleCompletion(TaskModel task, bool? value) {
    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: value ?? false,
    );
    ref.read(taskListProvider.notifier).updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    final taskListState = ref.watch(taskListProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // Trigger filtering when the screen is built or filters change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterTasks(taskListState.tasks);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('My Tasks',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Priority Filter
          Tooltip(
            message: 'Filter by Priority',
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  selectedPriority = value;
                });
                _filterTasks(taskListState.tasks);
              },
              icon: const Icon(Icons.filter_list, color: Colors.white),
              itemBuilder: (_) => const [
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
            child: PopupMenuButton<String?>(
              onSelected: (value) {
                setState(() {
                  showCompleted = value == 'All' ? null : (value == 'Completed');
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
                authNotifier.signOut();
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: taskListState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskListState.filteredTasks.isEmpty
              ? const Center(child: Text("No tasks match your filter."))
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(taskListProvider.notifier).fetchTasks();
                  },
                  child: ListView.builder(
                    itemCount: taskListState.filteredTasks.length,
                    itemBuilder: (_, index) {
                      final task = taskListState.filteredTasks[index];
                      return Dismissible(
                        key: Key(task.id ?? ''),
                        onDismissed: (_) {
                          if (task.id != null) {
                            ref.read(taskListProvider.notifier).deleteTask(task.id!);
                          }
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
                          priority: TaskModel.priorityToString(task.priority).toLowerCase(),
                          isDone: task.isCompleted,
                          dueDate: task.dueDate,
                          onEdit: () => _editTask(task),
                          onToggle: (value) => _toggleCompletion(task, value),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: "Add Task",
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskFormScreen(onSave: (TaskModel newTask) {
              ref.read(taskListProvider.notifier).addTask(newTask).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task added successfully!'),
                  ),
                );
              });
            },
            ),
            )  );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),
    );
  }

  void _filterTasks(List<TaskModel> tasks) {
    List<TaskModel> filtered = tasks.where((task) {
      if (selectedPriority != 'All' &&
          TaskModel.priorityToString(task.priority).toLowerCase() != selectedPriority.toLowerCase()) {
        return false;
      }
      if (showCompleted != null && task.isCompleted != showCompleted) {
        return false;
      }
      return true;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Update the provider with filtered tasks
    if (mounted) {
      Future.microtask(() {
        try {
          ref.read(taskListProvider.notifier).setFilteredTasks(filtered);
        } catch (e) {
          debugPrint("Error updating filtered tasks: $e");
        }
      });
    }
  }
