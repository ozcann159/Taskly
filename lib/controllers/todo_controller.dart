import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/models/todo_model.dart';

class TodoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var todos = <Todo>[].obs;
  var searchQuery = ''.obs;
  var isLoading = false.obs;
  var selectedCategory = 'all'.obs;
  StreamSubscription<QuerySnapshot>? todosSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenAuthChanges();
  }

  void _listenAuthChanges() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchTodos(user.uid);
      } else {
        todosSubscription?.cancel();
        todos.clear();
      }
    });
  }

  void refreshTodos() {
    update();
  }

  void fetchTodos(String userId) {
    isLoading.value = true;
    if (userId.isNotEmpty) {
      todosSubscription = _firestore
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
            todos.value =
                snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList();
            isLoading.value = false;
          });
    }
  }

  @override
  void onClose() {
    todosSubscription?.cancel();
    super.onClose();
  }

  List<Todo> get filteredPendingTodos {
    return todos.where((todo) {
      // Önce tamamlanmamış olanları filtrele
      if (todo.isCompleted) return false;

      // Sonra arama sorgusuna göre filtrele
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!todo.title.toLowerCase().contains(query) &&
            !todo.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Son olarak kategoriye göre filtrele
      if (selectedCategory.value != 'all') {
        return todo.category.toString() == selectedCategory.value;
      }

      return true;
    }).toList();
  }

  List<Todo> get filteredCompletedTodos {
    return todos.where((todo) {
      // Önce tamamlanmış olanları filtrele
      if (!todo.isCompleted) return false;

      // Sonra arama sorgusuna göre filtrele
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!todo.title.toLowerCase().contains(query) &&
            !todo.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Son olarak kategoriye göre filtrele
      if (selectedCategory.value != 'all') {
        return todo.category.toString() == selectedCategory.value;
      }

      return true;
    }).toList();
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .add(todo.toFirestore());

      Get.back();
      Get.snackbar('Başarılı', 'Görev başarıyla eklendi');
    } catch (e) {
      Get.snackbar('Hata', 'Görev eklenirken bir hata oluştu');
    }
  }

  Future<void> updateTodo(String id, Todo todo) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .doc(id)
          .update(todo.toFirestore());

      Get.back();
      Get.snackbar('Başarılı', 'Görev başarıyla güncellendi');
    } catch (e) {
      Get.snackbar('Hata', 'Görev güncellenirken bir hata oluştu');
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .doc(todoId)
          .delete();

      Get.snackbar('Başarılı', 'Görev başarıyla silindi');
    } catch (e) {
      Get.snackbar('Hata', 'Görev silinirken bir hata oluştu');
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .doc(todo.id)
          .update({'isCompleted': !todo.isCompleted});

      Get.snackbar('Başarılı', 'Görev durumu güncellendi');
    } catch (e) {
      Get.snackbar('Hata', 'Görev durumu güncellenirken bir hata oluştu');
    }
  }
}
