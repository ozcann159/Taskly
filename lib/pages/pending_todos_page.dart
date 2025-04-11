import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_task_app/pages/todo_form_page.dart';

import '../controllers/todo_controller.dart';

class PendingTodosPage extends StatelessWidget {
  const PendingTodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoController todoController = Get.find();

    return Obx(() {
      final todos = todoController.filteredPendingTodos;
      if (todos.isEmpty) {
        return const Center(
            child: Text(
          'Henüz tamamlanmamış not yok',
          style: TextStyle(color: Colors.white),
        ));
      }
      return ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          var todo = todos[index];
          final createdAt =
              todo['createdAt']?.toDate(); // Timestamp'ı DateTime'a dönüştür
          final formattedDate = createdAt != null
              ? DateFormat('dd MMM yyyy').format(createdAt) // Tarihi formatla
              : 'Tarih Yok';

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: GestureDetector(
                onTap: () {
                  todoController.toggleTodoCompletion(todo.id, true);
                },
                child: todo['completed']
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.circle_outlined),
              ),
              title: Text(
                todo['title'] ?? 'Başlık Yok',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todo['description'] ?? 'Açıklama Yok'),
                  Text(
                    formattedDate,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              width: 300, // Genişlik
                              height: 400, // Yükseklik
                              child: TodoFormPage(
                                todoId: todo.id,
                                isUpdate: true,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, todo);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic todo) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Silme Onayı'),
        content: const Text('Bu notu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      // Onay verildiyse todo'yu sil
      await Get.find<TodoController>().deleteTodo(todo.id);
      Get.snackbar(
        'Başarılı',
        'Not başarıyla silindi.',
        backgroundColor: Colors.greenAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
