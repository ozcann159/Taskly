import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/controllers/todo_controller.dart';
import 'package:new_todo_app/models/todo_model.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TodoController controller = Get.find<TodoController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
      ),
      body: Obx(
        () {
          final todos = controller.todos;
          final completedTodos = todos.where((todo) => todo.isCompleted).length;
          final pendingTodos = todos.where((todo) => !todo.isCompleted).length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard(
                  context,
                  'Toplam Görev',
                  todos.length.toString(),
                  Icons.list,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  'Tamamlanan',
                  completedTodos.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  'Bekleyen',
                  pendingTodos.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
                const SizedBox(height: 24),
                Text(
                  'Kategori Dağılımı',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildCategoryStats(context, todos),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStats(BuildContext context, List<Todo> todos) {
    final categoryCount = <TodoCategory, int>{};
    for (var todo in todos) {
      categoryCount[todo.category] = (categoryCount[todo.category] ?? 0) + 1;
    }

    return Column(
      children: TodoCategory.values.map((category) {
        final count = categoryCount[category] ?? 0;
        return ListTile(
          leading: Icon(_getCategoryIcon(category)),
          title: Text(category.toString().split('.').last),
          trailing: Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(TodoCategory category) {
    switch (category) {
      case TodoCategory.work:
        return Icons.work;
      case TodoCategory.personal:
        return Icons.person;
      case TodoCategory.shopping:
        return Icons.shopping_cart;
      case TodoCategory.health:
        return Icons.health_and_safety;
      case TodoCategory.other:
        return Icons.category;
    }
  }
}