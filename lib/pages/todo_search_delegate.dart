import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/controllers/todo_controller.dart';
import 'package:new_todo_app/widgets/todo_card.dart';

class TodoSearchDelegate extends SearchDelegate<String> {
  final TodoController todoController;

  TodoSearchDelegate(this.todoController);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Arama yapmak için bir şeyler yazın'));
    }

    final isDarkMode = Get.isDarkMode;

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('todos')
              .where(
                'userId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid,
              )
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Görev bulunamadı'));
        }

        // Arama sonuçlarını filtrele
        final filteredDocs =
            snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final title = (data['title'] ?? '').toString().toLowerCase();
              final description =
                  (data['description'] ?? '').toString().toLowerCase();
              final searchQuery = query.toLowerCase();

              return title.contains(searchQuery) ||
                  description.contains(searchQuery);
            }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aramanızla eşleşen görev bulunamadı',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final id = doc.id;
            final title = data['title'] ?? '';
            final description = data['description'] ?? '';
            final dueDate = (data['dueDate'] as Timestamp).toDate();
            final isCompleted = data['isCompleted'] ?? false;
            final priority = data['priority'] ?? 1;
            final category = data['category'] ?? 'diğer';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TodoCard(
                id: id,
                title: title,
                description: description,
                dueDate: dueDate,
                isCompleted: isCompleted,
                priority: priority,
                category: category,
                onDelete: () {
                  FirebaseFirestore.instance
                      .collection('todos')
                      .doc(id)
                      .delete();
                  close(context, '');
                },
                onEdit: () {
                  close(context, '');
                  Get.toNamed(
                    '/todo-form',
                    arguments: {'todoId': id, 'isUpdate': true},
                  );
                },
                onToggleComplete: (value) {
                  if (value != null) {
                    FirebaseFirestore.instance
                        .collection('todos')
                        .doc(id)
                        .update({'isCompleted': value});
                  }
                },
                todo: data,
                onTap: () {
                  close(context, '');
                  Get.toNamed(
                    '/todo-form',
                    arguments: {'todoId': id, 'isUpdate': true},
                  );
                },
                onStatusChanged: (value) {
                  if (value != null) {
                    FirebaseFirestore.instance
                        .collection('todos')
                        .doc(id)
                        .update({'isCompleted': value});
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
