import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/controllers/todo_controller.dart';
import 'package:new_todo_app/widgets/todo_card.dart';
import 'package:intl/intl.dart';

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
    final backgroundColor = isDarkMode ? Color(0xFF121212) : Color(0xFFF5F5F5);
    final cardColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

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
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Bir hata oluştu: ${snapshot.error}',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

        // Arama filtrelemesi
        final filteredDocs =
            snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final description = data['description'] ?? '';

              return title.toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  description.toString().toLowerCase().contains(
                    query.toLowerCase(),
                  );
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

            // Öncelik etiketi
            String priorityLabel = '';
            Color priorityColor = Colors.green;

            if (priority == 1) {
              priorityLabel = 'Düşük';
              priorityColor = Colors.green;
            } else if (priority == 2) {
              priorityLabel = 'Orta';
              priorityColor = Colors.orange;
            } else {
              priorityLabel = 'Yüksek';
              priorityColor = Colors.red;
            }

            // Kategori rengini belirle
            Color categoryColor;
            IconData categoryIcon;

            switch (category) {
              case 'iş':
                categoryColor = Colors.blue;
                categoryIcon = Icons.work;
                break;
              case 'kişisel':
                categoryColor = Colors.purple;
                categoryIcon = Icons.person;
                break;
              case 'alışveriş':
                categoryColor = Colors.amber;
                categoryIcon = Icons.shopping_cart;
                break;
              case 'sağlık':
                categoryColor = Colors.red;
                categoryIcon = Icons.favorite;
                break;
              case 'eğitim':
                categoryColor = Colors.teal;
                categoryIcon = Icons.school;
                break;
              default:
                categoryColor = Colors.grey;
                categoryIcon = Icons.category;
            }

            final formattedDate = DateFormat('dd MMM yyyy').format(dueDate);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: cardColor,
              child: InkWell(
                onTap: () {
                  Get.toNamed(
                    '/todo-form',
                    arguments: {'todoId': id, 'isUpdate': true},
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve öncelik
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 16,
                                  color: priorityColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  priorityLabel,
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
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          description,
                          style: TextStyle(color: secondaryTextColor),
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
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category,
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
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
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
      },
    );
  }
}
