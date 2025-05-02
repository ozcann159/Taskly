import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/pages/login_page.dart';
import 'package:new_todo_app/pages/profile_page.dart';
import 'package:new_todo_app/pages/register_page.dart';
import 'package:new_todo_app/pages/statistics_page.dart';
import 'package:new_todo_app/pages/todo_form_page.dart';
import 'package:new_todo_app/pages/todo_page.dart';

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
      initialRoute: isLoggedIn ? '/todo-page' : '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(name: '/todo-page', page: () => const TodoPage()),
        GetPage(name: '/statistics', page: () => const StatisticsPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(
          name: '/todo-form',
          page: () => const TodoFormPage(todoId: null, isUpdate: false),
        ),
      ],
    );
  }
}
