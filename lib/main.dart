import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/presentation/pages/auth/forgot_password_page.dart';
import 'package:new_todo_app/presentation/pages/auth/login_page.dart';
import 'package:new_todo_app/presentation/pages/auth/register_page.dart';
import 'package:new_todo_app/presentation/pages/profile/profile_page.dart';
import 'package:new_todo_app/presentation/pages/statistics/statistics_page.dart';
import 'package:new_todo_app/presentation/pages/todo/todo_detail_page.dart';
import 'package:new_todo_app/presentation/pages/todo/todo_form_page.dart';
import 'package:new_todo_app/presentation/pages/todo/todo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      themeMode: ThemeMode.system,
      initialRoute: isLoggedIn ? '/todo' : '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/forgot-password', page: () => ForgotPasswordPage()),
        GetPage(name: '/todo', page: () => const TodoPage()),
        GetPage(name: '/todo-page', page: () => const TodoPage()),
        GetPage(name: '/statistics', page: () => const StatisticsPage()),
        GetPage(name: '/todo-detail', page: () => TodoDetailPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(
          name: '/todo-form',
          page: () => const TodoFormPage(todoId: null, isUpdate: false),
        ),
      ],
    );
  }
}
