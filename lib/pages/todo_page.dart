import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_task_app/const/color.dart';

import '../controllers/todo_controller.dart';
import 'completed_todos_page.dart';
import 'pending_todos_page.dart';
import 'todo_form_page.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoController todoController = Get.put(TodoController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColors,
        appBar: AppBar(
          backgroundColor: backgroundColors,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAllNamed('/login');
              },
            ),
          ],
          title: const Text('Yapılacaklar'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        prefixIcon: Icon(
                          Icons.search,
                          color: tdBlack,
                          size: 20,
                        ),
                        prefixIconConstraints:
                            BoxConstraints(maxHeight: 40, minWidth: 35),
                        border: InputBorder.none,
                        hintText: 'Ara',
                        hintStyle: TextStyle(color: tdGrey),
                      ),
                      onChanged: (value) {
                        todoController.searchQuery.value = value;
                      },
                    ),
                  ),
                  const TabBar(
                    labelStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    tabs: [
                      Tab(
                        text: 'Tamamlanmamış',
                      ),
                      Tab(
                        text: 'Tamamlanmış',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            PendingTodosPage(),
            CompletedTodosPage(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.indigo,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Center(),
                  content: Container(
                    width: 300, // Genişlik
                    height: 400, // Yükseklik
                    child: const Column(
                      children: [
                        Expanded(
                          child: TodoFormPage(todoId: null, isUpdate: false),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          tooltip: 'Todo Ekle',
          child: const Icon(
            Icons.add,
            color: Colors.white, // Icon rengi
          ),
        ),
      ),
    );
  }
}
