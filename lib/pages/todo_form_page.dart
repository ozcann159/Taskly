import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoFormPage extends StatefulWidget {
  final String? todoId;
  final bool isUpdate;

  const TodoFormPage({super.key, this.todoId, required this.isUpdate});

  @override
  _TodoFormPageState createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedCategory = 'kişisel';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _priority = 1; // 1: Düşük, 2: Orta, 3: Yüksek

  final List<Map<String, dynamic>> _categories = [
    {'id': 'kişisel', 'name': 'Kişisel', 'icon': Icons.person},
    {'id': 'iş', 'name': 'İş', 'icon': Icons.work},
    {'id': 'alışveriş', 'name': 'Alışveriş', 'icon': Icons.shopping_cart},
    {'id': 'eğitim', 'name': 'Eğitim', 'icon': Icons.school},
    {'id': 'sağlık', 'name': 'Sağlık', 'icon': Icons.health_and_safety},
    {'id': 'diğer', 'name': 'Diğer', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.todoId != null) {
      _loadTodoData();
    }
  }

  void _loadTodoData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todoDoc =
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(widget.todoId)
              .get();

      if (todoDoc.exists) {
        final data = todoDoc.data() as Map<String, dynamic>;
        titleController.text = data['title'] ?? '';
        descriptionController.text = data['description'] ?? '';

        if (data['dueDate'] != null) {
          final dueDate = (data['dueDate'] as Timestamp).toDate();
          setState(() {
            _selectedCategory = data['category'] ?? 'kişisel';
            _selectedDate = dueDate;
            _selectedTime = TimeOfDay(
              hour: dueDate.hour,
              minute: dueDate.minute,
            );
          });
        }

        setState(() {
          _priority = data['priority'] ?? 1;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Veri yüklenirken bir hata oluştu: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveTodo() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        Get.snackbar(
          'Uyarı',
          'Lütfen bir tarih seçin',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Tarih ve saat birleştirme
        DateTime dueDateTime = _selectedDate!;
        if (_selectedTime != null) {
          dueDateTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
        }

        @override
        void initState() {
          super.initState();
          if (widget.isUpdate && widget.todoId != null) {
            _loadTodoData();
          }
        }

        // Kullanıcı ID'sini al
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Kullanıcı oturumu bulunamadı');
        }

        final todoData = {
          'userId': user.uid,
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'dueDate': Timestamp.fromDate(dueDateTime),
          'category': _selectedCategory,
          'priority': _priority,
          'isCompleted': widget.isUpdate ? null : false,
          'updatedAt': Timestamp.now(),
        };

        if (!widget.isUpdate) {
          todoData['createdAt'] = Timestamp.now();
        }

        if (widget.isUpdate && widget.todoId != null) {
          // Güncelleme
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(widget.todoId)
              .update(todoData);

          Get.back(result: true);
          Get.snackbar(
            'Başarılı',
            'Görev başarıyla güncellendi',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            margin: const EdgeInsets.all(10),
            borderRadius: 10,
            duration: const Duration(seconds: 3),
          );
        } else {
          // Yeni ekleme
          await FirebaseFirestore.instance.collection('todos').add(todoData);

          Get.back(result: true);
          Get.snackbar(
            'Başarılı',
            'Görev başarıyla eklendi',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            margin: const EdgeInsets.all(10),
            borderRadius: 10,
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Hata',
          'İşlem sırasında bir hata oluştu: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpdate ? 'Görevi Düzenle' : 'Yeni Görev Ekle'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body:
          _isLoading && widget.isUpdate
              ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
              : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            "Kategori",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children:
                                  _categories.map((category) {
                                    return RadioListTile<String>(
                                      title: Row(
                                        children: [
                                          Icon(
                                            category['icon'],
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(category['name']),
                                        ],
                                      ),
                                      value: category['id'],
                                      groupValue: _selectedCategory,
                                      activeColor: colorScheme.primary,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCategory = value!;
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                          Text(
                            "Görev Başlığı",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: 'Görev başlığını girin',
                              prefixIcon: Icon(
                                Icons.title,
                                color: colorScheme.primary,
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Görev başlığı gerekli';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Açıklama",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Görev açıklamasını girin',
                              prefixIcon: Icon(
                                Icons.description,
                                color: colorScheme.primary,
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Bitiş Tarihi",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedDate == null
                                        ? 'Tarih seçin'
                                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                    style: TextStyle(
                                      color:
                                          _selectedDate == null
                                              ? colorScheme.onSurface
                                                  .withOpacity(0.6)
                                              : colorScheme.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Bitiş Saati (Opsiyonel)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedTime == null
                                        ? 'Saat seçin (opsiyonel)'
                                        : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color:
                                          _selectedTime == null
                                              ? colorScheme.onSurface
                                                  .withOpacity(0.6)
                                              : colorScheme.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Öncelik",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                RadioListTile<int>(
                                  title: const Text('Düşük'),
                                  value: 1,
                                  groupValue: _priority,
                                  activeColor: colorScheme.primary,
                                  onChanged: (value) {
                                    setState(() {
                                      _priority = value!;
                                    });
                                  },
                                ),
                                RadioListTile<int>(
                                  title: const Text('Orta'),
                                  value: 2,
                                  groupValue: _priority,
                                  activeColor: colorScheme.primary,
                                  onChanged: (value) {
                                    setState(() {
                                      _priority = value!;
                                    });
                                  },
                                ),
                                RadioListTile<int>(
                                  title: const Text('Yüksek'),
                                  value: 3,
                                  groupValue: _priority,
                                  activeColor: colorScheme.primary,
                                  onChanged: (value) {
                                    setState(() {
                                      _priority = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveTodo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.onPrimary,
                                        ),
                                      )
                                      : Text(
                                        widget.isUpdate
                                            ? 'Görevi Güncelle'
                                            : 'Görevi Kaydet',
                                        style: const TextStyle(
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
              ),
    );
  }
}
