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
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.todoId != null) {
      _loadTodoData();
    }
  }

  Future<void> _loadTodoData() async {
    DocumentSnapshot todo = await FirebaseFirestore.instance
        .collection('todos')
        .doc(user!.uid)
        .collection('userTodos')
        .doc(widget.todoId)
        .get();

    Map<String, dynamic>? data = todo.data() as Map<String, dynamic>?;
    if (data != null) {
      titleController.text = data['title'] ?? '';
      descriptionController.text = data['description'] ?? '';
    }
  }

  Future<void> _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      try {
        final title = titleController.text.trim();
        final description = descriptionController.text.trim();
        if (title.isEmpty) {
          Get.snackbar('Hata', 'Başlık boş olamaz!',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
         if (description.isEmpty) {
          Get.snackbar('Hata', 'Açıklama boş olamaz!',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
        if (widget.isUpdate && widget.todoId != null) {
          // Todo güncelle
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(user!.uid)
              .collection('userTodos')
              .doc(widget.todoId)
              .update({
            'title': titleController.text,
            'description': descriptionController.text,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Yeni todo ekle
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(user!.uid)
              .collection('userTodos')
              .add({
            'title': titleController.text,
            'description': descriptionController.text,
            'completed': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        Get.back();
      } catch (e) {
        Get.snackbar('Hata', e.toString(),
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(widget.isUpdate ? 'Todo Güncelle' : 'Yeni Todo Ekle'),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Başlık',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Başlık gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Açıklama', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Açıklama gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Kapat'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _saveTodo,
                      child: Text(widget.isUpdate ? 'Güncelle' : 'Ekle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
