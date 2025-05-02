import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_todo_app/models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Todo>> getTodos() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.value(
        [],
      ); // Kullanıcı giriş yapmamışsa boş bir liste döndür
    }
    return _db
        .collection('todos')
        .doc(userId)
        .collection('userTodos')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList();
        });
  }

  // Belirli bir todo'yu ID ile getirir
  Future<Todo?> getTodoById(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null; // Kullanıcı giriş yapmamışsa null döndür
    final doc =
        await _db
            .collection('todos')
            .doc(userId)
            .collection('userTodos')
            .doc(id)
            .get();
    return doc.exists ? Todo.fromFirestore(doc) : null;
  }

  // Yeni bir todo ekler
  Future<void> addTodo(Todo todo) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _db
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .add(todo.toFirestore());
    }
  }

  // Var olan bir todo'yu günceller
  Future<void> updateTodo(String id, Todo todo) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _db
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .doc(id)
          .update(todo.toFirestore());
    }
  }

  // Var olan bir todo'yu siler
  Future<void> deleteTodo(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _db
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .doc(id)
          .delete();
    }
  }
}
