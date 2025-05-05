import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? todoId = Get.arguments as String?;

    if (todoId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Hata')),
        body: Center(
          child: Text('Görev bulunamadı', style: GoogleFonts.poppins()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Görev Detayı', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Get.toNamed('/todo-form', arguments: todoId),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('todos').doc(todoId).get(),
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

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Görev bulunamadı', style: GoogleFonts.poppins()),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final title = data['title'] ?? '';
          final description = data['description'] ?? '';
          final isCompleted = data['isCompleted'] ?? false;
          final dueDate =
              data['dueDate'] != null
                  ? (data['dueDate'] as Timestamp).toDate()
                  : null;

          // Kategori bilgisi
          String categoryId;
          if (data['category'] is Map<String, dynamic>) {
            categoryId =
                (data['category'] as Map<String, dynamic>)['id'] as String? ??
                'diğer';
          } else if (data['category'] is String) {
            categoryId = data['category'] as String;
          } else {
            categoryId = 'diğer';
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey : null,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Durum
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  isCompleted
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              isCompleted ? 'Tamamlandı' : 'Devam Ediyor',
                              style: GoogleFonts.poppins(
                                color:
                                    isCompleted ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          if (dueDate != null) ...[
                            SizedBox(width: 8),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: 24),

                      // Açıklama
                      if (description.isNotEmpty) ...[
                        Text(
                          'Açıklama',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            description,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              height: 1.5,
                              color: isCompleted ? Colors.grey : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Get.until((route) => route.settings.name == '/todo');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6200EE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tamam',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
