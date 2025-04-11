import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TodoController extends GetxController {
  var todos = <DocumentSnapshot>[].obs;
  var searchQuery = ''.obs;
  StreamSubscription<QuerySnapshot>? todosSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenAuthChanges(); // Auth değişikliklerini dinlemeye başlayın
  }

  void _listenAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchTodos(user.uid); // Kullanıcının uid'sini iletin
      } else {
        todosSubscription?.cancel();
        todos.clear(); // Kullanıcı oturumu kapalıysa todo listesini temizleyin
      }
    });
  }

  void fetchTodos(String userId) {
    if (userId.isNotEmpty) {
      todosSubscription = FirebaseFirestore.instance
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        todos.value = snapshot.docs;
      });
    }
  }

  @override
  void onClose() {
    todosSubscription?.cancel(); // Dinleyiciyi temizliyoruz
    super.onClose();
  }

  List<DocumentSnapshot> get filteredPendingTodos {
    if (searchQuery.isEmpty) {
      return todos.where((todo) => !(todo['completed'] ?? false)).toList();
    } else {
      return todos
          .where((todo) =>
              !(todo['completed'] ?? false) &&
              ((todo['title']
                          ?.toLowerCase()
                          .contains(searchQuery.toLowerCase()) ??
                      false) ||
                  (todo['description']
                          ?.toLowerCase()
                          .contains(searchQuery.toLowerCase()) ??
                      false)))
          .toList();
    }
  }

  List<DocumentSnapshot> get filteredCompletedTodos {
    if (searchQuery.isEmpty) {
      return todos.where((todo) => todo['completed'] ?? false).toList();
    } else {
      return todos
          .where((todo) =>
              (todo['completed'] ?? false) &&
              ((todo['title']
                          ?.toLowerCase()
                          .contains(searchQuery.toLowerCase()) ??
                      false) ||
                  (todo['description']
                          ?.toLowerCase()
                          .contains(searchQuery.toLowerCase()) ??
                      false)))
          .toList();
    }
  }

  Future<void> deleteTodo(String todoId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .doc(todoId)
          .delete();
      // Todos listesine yeni veriyi almak için fetchTodos'u çağırmak yerine snapshot listener'ı dinlemeye devam et
    }
  }

  Future<void> toggleTodoCompletion(String todoId, bool completed) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .doc(todoId)
          .update({'completed': completed});
      // Todos listesine yeni veriyi almak için fetchTodos'u çağırmak yerine snapshot listener'ı dinlemeye devam et
    }
  }
}
