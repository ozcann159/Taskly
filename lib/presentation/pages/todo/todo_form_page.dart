import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TodoFormPage extends StatefulWidget {
  const TodoFormPage({Key? key, required todoId, required bool isUpdate})
    : super(key: key);

  @override
  State<TodoFormPage> createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  String _selectedCategory = 'kişisel';
  int _priority = 1;
  String? _todoId;
  bool _isLoading = false;
  bool _reminderEnabled = false;
  int _reminderHours = 1;

  // Kategori listesi
  final List<Map<String, dynamic>> _categories = [
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

    // Eğer düzenleme modundaysa, mevcut görevi yükle
    if (Get.arguments != null) {
      _todoId = Get.arguments;
      _loadTodo();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Mevcut görevi yükleme
  Future<void> _loadTodo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(_todoId)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          _titleController.text = data['title'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _selectedDate = (data['dueDate'] as Timestamp).toDate();
          _selectedCategory = data['category'] ?? 'kişisel';
          _priority = data['priority'] ?? 1;
          _reminderEnabled = data['reminderEnabled'] ?? false;
          _reminderHours = data['reminderHours'] ?? 1;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Görev yüklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tarih seçici
  Future<void> _selectDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF6200EE);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
              onSurface: isDarkMode ? Colors.white : Colors.black87,
            ),
            dialogBackgroundColor:
                isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Görev kaydetme
  Future<void> _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Görev verilerini hazırla
        Map<String, dynamic> todoData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'dueDate': Timestamp.fromDate(_selectedDate),
          'category': _selectedCategory,
          'priority': _priority,
          'isCompleted': false,
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'reminderEnabled': _reminderEnabled,
          'reminderHours': _reminderHours,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Yeni görev oluşturma veya güncelleme
        if (_todoId != null) {
          // Güncelleme
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(_todoId)
              .update(todoData);

          Get.snackbar(
            'Başarılı',
            'Görev başarıyla güncellendi',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          // Yeni ekleme
          todoData['createdAt'] = FieldValue.serverTimestamp();

          await FirebaseFirestore.instance.collection('todos').add(todoData);

          Get.snackbar(
            'Başarılı',
            'Görev başarıyla oluşturuldu',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }

        // Ana sayfaya dön
        Get.until((route) => route.settings.name == '/todo');
      } catch (e) {
        Get.snackbar(
          'Hata',
          'Görev kaydedilirken bir hata oluştu: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
          _todoId != null ? 'Görevi Düzenle' : 'Yeni Görev',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: primaryColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.check, color: primaryColor),
            label: Text(
              'Kaydet',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            onPressed: _isLoading ? null : _saveTodo,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Başlık',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _titleController,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: 'Görev başlığını girin',
                                  hintStyle: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                  filled: true,
                                  fillColor:
                                      isDarkMode
                                          ? Color(0xFF2A2A2A)
                                          : Color(0xFFF5F5F7),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.title,
                                    color: primaryColor,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen bir başlık girin';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Açıklama
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Açıklama',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _descriptionController,
                                style: TextStyle(color: textColor),
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Görev açıklamasını girin (isteğe bağlı)',
                                  hintStyle: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                  filled: true,
                                  fillColor:
                                      isDarkMode
                                          ? Color(0xFF2A2A2A)
                                          : Color(0xFFF5F5F7),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.description,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tarih ve Kategori
                        Row(
                          children: [
                            // Tarih
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Son Tarih',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () => _selectDate(context),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isDarkMode
                                                  ? Color(0xFF2A2A2A)
                                                  : Color(0xFFF5F5F7),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: primaryColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat(
                                                'dd MMM yyyy',
                                              ).format(_selectedDate),
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Kategori
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kategori',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    final isSelected =
                                        _selectedCategory == category['id'];
                                    final categoryColor =
                                        category['color'] as Color;

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = category['id'];
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 200),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? categoryColor
                                                    : isDarkMode
                                                    ? Color(0xFF2A2A2A)
                                                    : Color(0xFFF0F0F0),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? categoryColor
                                                      : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                category['icon'],
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : categoryColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                category['name'],
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : textColor,
                                                  fontWeight:
                                                      isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Öncelik
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Öncelik',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildPriorityButton(
                                    1,
                                    'Düşük',
                                    Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildPriorityButton(
                                    2,
                                    'Orta',
                                    Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildPriorityButton(3, 'Yüksek', Colors.red),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Hatırlatıcı
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Hatırlatıcı',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  Switch(
                                    value: _reminderEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _reminderEnabled = value;
                                      });
                                    },
                                    activeColor: primaryColor,
                                  ),
                                ],
                              ),
                              if (_reminderEnabled) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Son tarihten ne kadar önce hatırlatılsın?',
                                  style: TextStyle(color: secondaryTextColor),
                                ),
                                const SizedBox(height: 8),
                                Slider(
                                  value: _reminderHours.toDouble(),
                                  min: 1,
                                  max: 24,
                                  divisions: 23,
                                  label: '$_reminderHours saat önce',
                                  onChanged: (value) {
                                    setState(() {
                                      _reminderHours = value.toInt();
                                    });
                                  },
                                  activeColor: primaryColor,
                                ),
                                Text(
                                  '$_reminderHours saat önce hatırlat',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Kaydet butonu
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveTodo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Kaydet',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildPriorityButton(int value, String label, Color color) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final isSelected = _priority == value;

    return InkWell(
      onTap: () {
        setState(() {
          _priority = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color
                  : isDarkMode
                  ? Color(0xFF2A2A2A)
                  : Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.flag,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
