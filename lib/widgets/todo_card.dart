import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_todo_app/models/todo_model.dart';
import 'package:intl/intl.dart';

class TodoCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final int priority;
  final String category;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Function(bool) onToggleComplete;

  // İsteğe bağlı parametreler ekleyin
  final Map<String, dynamic>? todo; // İsteğe bağlı yapın
  final VoidCallback? onTap; // İsteğe bağlı yapın
  final ValueChanged<bool?>?
  onStatusChanged; // Burayı ValueChanged tipi ile değiştirin

  const TodoCard({
    Key? key,
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.priority,
    required this.category,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleComplete,
    this.todo, // İsteğe bağlı
    this.onTap, // İsteğe bağlı
    this.onStatusChanged, // İsteğe bağlı
  }) : super(key: key);

  Color _getPriorityColor() {
    switch (priority) {
      case TodoPriority.high:
        return Colors.red.withOpacity(0.8);
      case TodoPriority.medium:
        return Colors.orange.withOpacity(0.8);
      case TodoPriority.low:
        return Colors.green.withOpacity(0.8);
      default:
        return Colors.blue.withOpacity(0.8); // Default fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo?['isCompleted'] ?? false, // Map üzerinden erişim
          onChanged: onStatusChanged, // onChanged doğru şekilde kullanılıyor
        ),
        title: Text(
          todo?['title'] ?? '', // Map üzerinden erişim
          style: TextStyle(
            decoration:
                todo?['isCompleted'] == true
                    ? TextDecoration.lineThrough
                    : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todo?['description'] ?? ''), // Map üzerinden erişim
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(
                    (todo?['dueDate'] as Timestamp)
                        .toDate(), // Burada Timestamp'ı DateTime'a çeviriyoruz
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (todo?['priority'] ?? 0).toString().toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
