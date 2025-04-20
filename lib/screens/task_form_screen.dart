import 'package:flutter/material.dart';
import 'package:interassignment1/models/task_model.dart';

class TaskFormScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final Priority? initialPriority;
  final DateTime? initialDueDate;
  final bool isEditMode;
  final void Function(TaskModel) onSave;

  const TaskFormScreen({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialPriority,
    this.initialDueDate,
    this.isEditMode = false,
    required this.onSave,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  Priority _selectedPriority = Priority.low;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _selectedPriority = widget.initialPriority ?? Priority.low;
    _selectedDate = widget.initialDueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final newTask = TaskModel(
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _selectedPriority,
        dueDate: _selectedDate,
        isCompleted: false,
      );
      
      widget.onSave(newTask);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.isEditMode ? 'Edit Task' : 'Add Task',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Priority Dropdown
                DropdownButtonFormField<Priority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: Priority.values.map((Priority priority) {
                    return DropdownMenuItem<Priority>(
                      value: priority,
                      child: Text(TaskModel.priorityToString(priority)),
                    );
                  }).toList(),
                  onChanged: (Priority? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPriority = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Due Date Picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.isEditMode ? 'Update Task' : 'Add Task',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}