import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_task_app/pages/login_page.dart';
import 'package:todo_task_app/pages/register_page.dart';
import 'package:todo_task_app/pages/todo_form_page.dart';
import 'package:todo_task_app/pages/todo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Kullanıcı oturum açmış mı kontrol et
  final user = FirebaseAuth.instance.currentUser;
  runApp(MyApp(isLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Uygulaması',
      initialRoute: isLoggedIn ? '/todo-page' : '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(name: '/todo-page', page: () => const TodoPage()),
        GetPage(
          name: '/todo-form',
          page: () => const TodoFormPage(todoId: null, isUpdate: false),
        ),
      ],
    );
  }
}
