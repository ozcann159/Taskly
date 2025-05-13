import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/services.dart';
import 'package:new_todo_app/presentation/controllers/todo_controller.dart';
import 'package:new_todo_app/presentation/pages/todo/todo_search_delegate.dart';

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
    DateTime dueDate;
    if (data['dueDate'] != null) {
      dueDate = (data['dueDate'] as Timestamp).toDate();
    } else {
      dueDate = DateTime.now(); // Varsayılan değer
    }
    //final dueDate = (data['dueDate'] as Timestamp).toDate();

    final isCompleted = data['isCompleted'] ?? false;
    final priority = data['priority'] ?? 1;
    final category = data['category'] ?? 'diğer';

    // Dark mod kontrolü
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final completedTextColor = Colors.grey;

    // Kategori bilgilerini al
    final categoryInfo = _categories.firstWhere(
      (cat) => cat['id'] == category,
      orElse: () => _categories.first,
    );

    // Öncelik etiketi
    String priorityLabel = '';
    Color priorityColor = Colors.green;

    if (priority == 1) {
      priorityLabel = 'Düşük';
      priorityColor = Colors.green;
    } else if (priority == 2) {
      priorityLabel = 'Orta';
      priorityColor = Colors.orange;
    } else if (priority == 3) {
      priorityLabel = 'Yüksek';
      priorityColor = Colors.red;
    }

    // Tarih formatı
    String dateText =
        isCompleted
            ? 'Tamamlandı: ${dueDate.day} ${_getMonthName(dueDate.month)} ${dueDate.year}'
            : 'Son Tarih: ${dueDate.day} ${_getMonthName(dueDate.month)} ${dueDate.year}';

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              'Sil',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          // iOS için Cupertino diyalog
          return await showCupertinoDialog<bool>(
            context: context,
            builder:
                (context) => CupertinoAlertDialog(
                  title: Text('Görevi Sil'),
                  content: Text(
                    'Bu görevi silmek istediğinizden emin misiniz?',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('İptal'),
                      isDefaultAction: true,
                    ),
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Sil'),
                      isDestructiveAction: true,
                    ),
                  ],
                ),
          );
        } else {
          // Android için Material diyalog
          return await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Görevi Sil'),
                  content: Text(
                    'Bu görevi silmek istediğinizden emin misiniz?',
                  ),
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
        }
      },
      onDismissed: (direction) {
        // Silme işlemini gerçekleştir
        FirebaseFirestore.instance.collection('todos').doc(id).delete().then((
          _,
        ) {
          // Başarı bildirimi
          Get.snackbar(
  'Başarılı',
  'Görev başarıyla silindi',
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.green[600],
  colorText: Colors.white,
  borderRadius: 10,
  margin: EdgeInsets.all(12),
  duration: Duration(seconds: 2),
  icon: Icon(Icons.check_circle_outline, color: Colors.white),
  shouldIconPulse: true,
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  snackStyle: SnackStyle.FLOATING,
);
        });
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol taraf - Tamamlama checkbox
              Container(
                margin: EdgeInsets.only(right: 12, top: 2),
                child: InkWell(
                  onTap: () => _toggleTodoComplete(id, !isCompleted),
                  child: Container(
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
                ),
              ),

              // Orta kısım - İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve öncelik
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration:
                                  isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                              color:
                                  isCompleted ? completedTextColor : textColor,
                            ),
                          ),
                        ),
                        if (!isCompleted && priority > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              priorityLabel,
                              style: TextStyle(
                                color: priorityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Açıklama (varsa)
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isCompleted
                                    ? completedTextColor
                                    : secondaryTextColor,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),

                    // Alt bilgiler
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          // Kategori
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (categoryInfo['color'] as Color)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  categoryInfo['icon'] as IconData,
                                  size: 12,
                                  color: categoryInfo['color'] as Color,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  categoryInfo['name'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: categoryInfo['color'] as Color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 8),

                          // Tarih
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  dateText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sağ taraf - Düzenleme butonu
              if (!isCompleted)
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                  onPressed: () => _editTodo(id),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Ay adını döndüren yardımcı fonksiyon
  String _getMonthName(int month) {
    const months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
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
    // Kullanıcıya silme işlemini onaylatma (Cupertino tarzında)
    bool? confirm = await showCupertinoDialog<bool>(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text('Görevi Sil'),
            content: Text('Bu görevi silmek istediğinizden emin misiniz?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: Text('İptal'),
                isDefaultAction: true,
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Sil'),
                isDestructiveAction: true,
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('todos').doc(id).delete();

      // Cupertino tarzında başarı bildirimi
      showCupertinoModalPopup(
        context: context,
        builder:
            (context) => CupertinoActionSheet(
              title: Text('Başarılı'),
              message: Text('Görev başarıyla silindi'),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tamam'),
                ),
              ],
            ),
      );
    }
  }

  void _editTodo(String id) async {
    final result = await Get.toNamed('/todo-form', arguments: id);

    // Eğer sonuç true ise (başarılı kaydetme), görev listesini yenile
    if (result == true) {
      setState(() {
        // Sayfayı yenile
      });
    }
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
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // Kategori filtreleme
                final filteredDocs =
                    _selectedCategory == 'tümü'
                        ? docs
                        : docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['category'] == _selectedCategory;
                        }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Bekleyen görev bulunamadı',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => Get.toNamed('/todo-form'),
                          icon: Icon(Icons.add),
                          label: Text('Yeni Görev Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
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
                    return _buildTodoCard(filteredDocs[index]);
                  },
                );
              },
            ),

            // Tamamlanan görevler - Aynı UI yapısı
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('todos')
                      .where(
                        'userId',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                      )
                      .where('isCompleted', isEqualTo: true)
                      .orderBy('dueDate') // Sadece tek bir alana göre sıralama
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
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // Kategori filtreleme
                final filteredDocs =
                    _selectedCategory == 'tümü'
                        ? docs
                        : docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['category'] == _selectedCategory;
                        }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tamamlanan görev bulunamadı',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
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
                    return _buildTodoCard(filteredDocs[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/todo-form'),
        backgroundColor: primaryColor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Yeni Görev',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
