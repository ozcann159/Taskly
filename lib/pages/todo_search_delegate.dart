import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/controllers/todo_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoSearchDelegate extends SearchDelegate<String> {
  final TodoController todoController;

  TodoSearchDelegate(this.todoController);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Görev aramak için bir şeyler yazın',
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Color(0xFF121212) : Color(0xFFF5F5F7);

    return Container(
      color: backgroundColor,
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('todos')
                .where('title', isGreaterThanOrEqualTo: query)
                .where('title', isLessThanOrEqualTo: query + '\uf8ff')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Bir hata oluştu: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Sonuç bulunamadı',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Farklı bir arama terimi deneyin',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final id = doc.id;
              final title = data['title'] ?? '';
              final description = data['description'] ?? '';
              final isCompleted = data['isCompleted'] ?? false;

              // Kategori bilgisi
              String categoryId;
              if (data['category'] is Map<String, dynamic>) {
                categoryId =
                    (data['category'] as Map<String, dynamic>)['id']
                        as String? ??
                    'diğer';
              } else if (data['category'] is String) {
                categoryId = data['category'] as String;
              } else {
                categoryId = 'diğer';
              }

              return Card(
                margin: EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isCompleted ? Color(0xFF6200EE) : Colors.transparent,
                      border: Border.all(
                        color: isCompleted ? Color(0xFF6200EE) : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    padding: EdgeInsets.all(2),
                    child:
                        isCompleted
                            ? Icon(Icons.check, size: 16, color: Colors.white)
                            : SizedBox(width: 16, height: 16),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle:
                      description.isNotEmpty
                          ? Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              decoration:
                                  isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                              color:
                                  isCompleted
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                            ),
                          )
                          : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCompleted)
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            close(context, '');
                            Get.toNamed('/todo-form', arguments: id);
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _deleteTodo(context, id);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    if (id != null && id.isNotEmpty) {
                      close(context, '');
                      Get.toNamed('/todo-detail', arguments: id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Görev ID bulunamadı'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteTodo(BuildContext context, String id) async {
    // mounted kontrolünü kaldırın
    // if (!mounted) return;  // Bu satırı kaldırın

    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Görevi Sil'),
            content: Text('Bu görevi silmek istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Sil'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('todos').doc(id).delete();

        // Bu kontrolü de kaldırın
        // if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev başarıyla silindi'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // }
      } catch (e) {
        // Bu kontrolü de kaldırın
        // if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // }
      }
    }
  }
}
