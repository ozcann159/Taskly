import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/todo_controller.dart';

class CompletedTodosPage extends StatelessWidget {
  const CompletedTodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoController todoController = Get.find();

    return Obx(() {
      final todos = todoController.filteredCompletedTodos;
      if (todos.isEmpty) {
        return const Center(
          child: Text(
            'No completed todos',
            style: TextStyle(color: Colors.white),
          ),
        );
      }
      return ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          var todo = todos[index];
          final createdAt =
              todo['createdAt']?.toDate(); // Timestamp'ı DateTime'a dönüştür
          final formattedDate = createdAt != null
              ? DateFormat('dd MMM yyyy').format(createdAt) // Tarihi formatla
              : 'No Date';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(
                todo['title'] ?? 'No Title',
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todo['description'] ?? 'No Description'),
                  Text(
                    formattedDate,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
