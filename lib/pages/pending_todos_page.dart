import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:new_todo_app/controllers/todo_controller.dart';
import 'package:new_todo_app/models/todo_model.dart';

class PendingTodosPage extends StatelessWidget {
  const PendingTodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoController todoController = Get.find();

    return Obx(() {
      final todos = todoController.filteredPendingTodos;
      if (todos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Henüz bekleyen görev yok',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/todo-form'),
                icon: const Icon(Icons.add),
                label: const Text('Yeni Görev Ekle'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: todos.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          var todo = todos[index];
          final formattedDate = DateFormat('dd MMM yyyy').format(todo.dueDate);
          final createdDate = DateFormat('dd MMM yyyy').format(todo.createdAt);

          // Öncelik rengini belirle
          Color priorityColor;
          switch (todo.priority) {
            case TodoPriority.high:
              priorityColor = Colors.red;
              break;
            case TodoPriority.medium:
              priorityColor = Colors.orange;
              break;
            default:
              priorityColor = Colors.green;
          }

          // Kategori rengini belirle
          Color categoryColor;
          IconData categoryIcon;
          switch (todo.category) {
            case TodoCategory.work:
              categoryColor = Colors.blue;
              categoryIcon = Icons.work;
              break;
            case TodoCategory.personal:
              categoryColor = Colors.purple;
              categoryIcon = Icons.person;
              break;
            case TodoCategory.shopping:
              categoryColor = Colors.amber;
              categoryIcon = Icons.shopping_cart;
              break;
            case TodoCategory.health:
              categoryColor = Colors.red;
              categoryIcon = Icons.favorite;
              break;
            default:
              categoryColor = Colors.grey;
              categoryIcon = Icons.category;
          }

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: priorityColor.withOpacity(0.3), width: 1),
            ),
            child: InkWell(
              onTap: () {
                Get.toNamed(
                  '/todo-form',
                  arguments: {'todoId': todo.id, 'isUpdate': true},
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve Öncelik
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            todo.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.flag, size: 16, color: priorityColor),
                              const SizedBox(width: 4),
                              Text(
                                todo.priority.toString().split('.').last,
                                style: TextStyle(
                                  color: priorityColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Açıklama
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      todo.description,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),

                  // Alt bilgiler
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        // Kategori
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                categoryIcon,
                                size: 16,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                todo.category.toString().split('.').last,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Tarih
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Son Tarih: $formattedDate',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // İşlem butonları
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          color: Colors.green,
                          onPressed: () {
                            todoController.toggleTodoStatus(todo);
                          },
                          tooltip: 'Tamamlandı olarak işaretle',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () {
                            Get.toNamed(
                              '/todo-form',
                              arguments: {'todoId': todo.id, 'isUpdate': true},
                            );
                          },
                          tooltip: 'Düzenle',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            _showDeleteConfirmation(
                              context,
                              todoController,
                              todo,
                            );
                          },
                          tooltip: 'Sil',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TodoController controller,
    Todo todo,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Görevi Sil'),
            content: const Text(
              'Bu görevi silmek istediğinizden emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  controller.deleteTodo(todo.id!);
                  Navigator.pop(context);
                },
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
