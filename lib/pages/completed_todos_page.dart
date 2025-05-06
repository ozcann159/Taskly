import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:new_todo_app/data/models/todo_model.dart';
import 'package:new_todo_app/presentation/controllers/todo_controller.dart';

class CompletedTodosPage extends StatelessWidget {
  const CompletedTodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoController todoController = Get.find();

    return Obx(() {
      final todos = todoController.filteredCompletedTodos;
      if (todos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.done_all,
                size: 64,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Henüz tamamlanmış görev yok',
                style: TextStyle(color: Colors.grey, fontSize: 16),
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
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey.shade100,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            todo.title,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Açıklama
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      todo.description,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  // Alt bilgiler
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                                color: categoryColor.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                todo.category.toString().split('.').last,
                                style: TextStyle(
                                  color: categoryColor.withOpacity(0.5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Tarih
                        Text(
                          'Tamamlandı: $formattedDate',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
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
                          icon: const Icon(Icons.refresh),
                          color: Colors.blue,
                          onPressed: () {
                            todoController.toggleTodoStatus(todo);
                          },
                          tooltip: 'Bekleyen olarak işaretle',
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
              'Bu tamamlanmış görevi silmek istediğinizden emin misiniz?',
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
