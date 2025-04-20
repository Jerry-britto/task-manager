import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool isDone;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isDone,
    required this.onToggle,
    required this.onEdit,
  });

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.green;
      default:
        return Colors.deepPurple; // For "Personal" or custom tags
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isDone,
            onChanged: onToggle,
            shape: const CircleBorder(),
            activeColor: Colors.deepPurple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    color: isDone ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      DateFormat('d MMM').format(dueDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: getPriorityColor(priority).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: getPriorityColor(priority),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.deepPurple),
            onPressed: onEdit,
            tooltip: 'Edit task',
          ),
        ],
      ),
    );
  }
}
