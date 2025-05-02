import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_todo_app/controllers/todo_controller.dart';
import 'package:new_todo_app/pages/todo_search_delegate.dart';
import 'package:new_todo_app/widgets/todo_card.dart';
import 'package:flutter/services.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TodoController todoController = Get.put(TodoController());
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'tümü';

  // Kategori listesi
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'tümü',
      'name': 'Tümü',
      'icon': Icons.list,
      'color': Color(0xFF6200EE),
    },
    {'id': 'iş', 'name': 'İş', 'icon': Icons.work, 'color': Color(0xFFFF9800)},
    {
      'id': 'kişisel',
      'name': 'Kişisel',
      'icon': Icons.person,
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'alışveriş',
      'name': 'Alışveriş',
      'icon': Icons.shopping_cart,
      'color': Color(0xFF9C27B0),
    },
    {
      'id': 'eğitim',
      'name': 'Eğitim',
      'icon': Icons.school,
      'color': Color(0xFF009688),
    },
    {
      'id': 'sağlık',
      'name': 'Sağlık',
      'icon': Icons.health_and_safety,
      'color': Color(0xFFE91E63),
    },
    {
      'id': 'diğer',
      'name': 'Diğer',
      'icon': Icons.more_horiz,
      'color': Color(0xFF607D8B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Durum çubuğu rengini ayarla
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Todo kartı oluşturma
  Widget _buildTodoCard(DocumentSnapshot doc) {
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
      priorityLabel = 'low';
      priorityColor = Colors.green;
    } else if (priority == 2) {
      priorityLabel = 'medium';
      priorityColor = Colors.orange;
    } else if (priority == 3) {
      priorityLabel = 'high';
      priorityColor = Colors.red;
    }

    // Tarih formatı
    String dateText =
        'Son Tarih: ${dueDate.day} ${_getMonthName(dueDate.month)} ${dueDate.year}';
    if (isCompleted) {
      dateText =
          'Tamamlandı: ${dueDate.day} ${_getMonthName(dueDate.month)} ${dueDate.year}';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve öncelik
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (!isCompleted && priority > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      priorityLabel,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Açıklama
          if (description.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),

          // Alt bilgiler
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kategori
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      category,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                // Tarih
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      dateText,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Butonlar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tamamla butonu (sadece tamamlanmamış görevlerde)
                if (!isCompleted)
                  IconButton(
                    icon: Icon(Icons.check_circle_outline, color: Colors.green),
                    onPressed: () => _toggleTodoComplete(id, true),
                    splashRadius: 20,
                  ),

                // Geri al butonu (sadece tamamlanmış görevlerde)
                if (isCompleted)
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.blue),
                    onPressed: () => _toggleTodoComplete(id, false),
                    splashRadius: 20,
                  ),

                // Düzenle butonu
                if (!isCompleted)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editTodo(id),
                    splashRadius: 20,
                  ),

                // Sil butonu
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTodo(id),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ay adını döndüren yardımcı fonksiyon
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  void _toggleTodoComplete(String id, bool? value) {
    if (value != null) {
      FirebaseFirestore.instance.collection('todos').doc(id).update({
        'isCompleted': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _deleteTodo(String id) async {
    // Kullanıcıya silme işlemini onaylatma
    bool confirm = await Get.dialog(
      AlertDialog(
        title: Text('Görevi Sil'),
        content: Text('Bu görevi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Sil'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance.collection('todos').doc(id).delete();
      Get.snackbar(
        'Başarılı',
        'Görev başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _editTodo(String id) {
    Get.toNamed('/todo-form', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Ana tema renkleri
    final primaryColor = Color(0xFF6200EE);
    final backgroundColor = isDarkMode ? Color(0xFF121212) : Color(0xFFF5F5F7);
    final cardColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Görevlerim',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: primaryColor, size: 26),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TodoSearchDelegate(todoController),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: primaryColor, size: 26),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Kategori filtreleme
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category['id'];
                      final categoryColor = category['color'] as Color;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category['icon'],
                                  size: 18,
                                  color:
                                      isSelected ? Colors.white : categoryColor,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    category['name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category['id'];
                              });
                            },
                            backgroundColor:
                                isDarkMode
                                    ? Color(0xFF2A2A2A)
                                    : Color(0xFFF0F0F0),
                            selectedColor: categoryColor,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : secondaryTextColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? Colors.transparent
                                        : Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: isSelected ? 3 : 0,
                            shadowColor: categoryColor.withOpacity(0.3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pending_actions,
                              size: 20,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bekleyen',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ... existing code ...
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tamamlanan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ... existing code ...
                    ],
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    indicatorColor: primaryColor,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                    labelColor: primaryColor,
                    unselectedLabelColor: secondaryTextColor,
                    onTap: (index) {
                      // Tab değiştiğinde animasyon
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Bekleyen görevler
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('todos')
                      .where(
                        'userId',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                      )
                      .where('isCompleted', isEqualTo: false)
                      .orderBy('dueDate', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
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
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.grey[800]!.withOpacity(0.3)
                                    : Colors.grey[100]!,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.task_alt,
                            size: 64,
                            color:
                                isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Henüz bekleyen görev bulunmuyor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Get.toNamed('/todo-form'),
                          icon: const Icon(Icons.add),
                          label: const Text('Yeni Görev Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Kategori filtreleme
                var filteredDocs = snapshot.data!.docs;
                if (_selectedCategory != 'tümü') {
                  filteredDocs =
                      filteredDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['category'] == _selectedCategory;
                      }).toList();
                }

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.grey[800]!.withOpacity(0.3)
                                    : Colors.grey[100]!,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.filter_list,
                            size: 64,
                            color:
                                isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Bu kategoride bekleyen görev bulunmuyor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
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
                    return _buildTodoCard(doc);
                  },
                );
              },
            ),

            // Tamamlanan görevler
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('todos')
                      .where(
                        'userId',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                      )
                      .where('isCompleted', isEqualTo: true)
                      .orderBy('updatedAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
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
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.grey[800]!.withOpacity(0.3)
                                    : Colors.grey[100]!,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color:
                                isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Henüz tamamlanan görev bulunmuyor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Kategori filtreleme
                var filteredDocs = snapshot.data!.docs;
                if (_selectedCategory != 'tümü') {
                  filteredDocs =
                      filteredDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['category'] == _selectedCategory;
                      }).toList();
                }

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.grey[800]!.withOpacity(0.3)
                                    : Colors.grey[100]!,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.filter_list,
                            size: 64,
                            color:
                                isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Bu kategoride tamamlanan görev bulunmuyor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
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
                    return _buildTodoCard(doc);
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/todo-form'),
          icon: const Icon(Icons.add),
          label: Text(
            'Yeni Görev',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          elevation: 4,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
