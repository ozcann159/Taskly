import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        Get.offNamed('/todo-page'); // Başarılı girişten sonra yönlendirme
      } on FirebaseAuthException catch (e) {
        Get.snackbar('Error', e.message ?? 'Bir hata oluştu');
      } catch (e) {
        Get.snackbar('Error', 'Bir hata oluştu');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d2630),
      appBar: AppBar(
        title: const Text(
          'Giriş Yap',
        ),
        backgroundColor: const Color(0xFF1d2630),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                "Hoşgeldiniz",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const Text(
                "Lütfen giriş yapın",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 50.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          labelText: 'E-posta',
                          labelStyle: const TextStyle(color: Colors.white60),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white38),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Geçerli bir e-posta girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.password,
                            color: Colors.white,
                          ),
                          labelText: 'Şifre',
                          labelStyle: const TextStyle(color: Colors.white60),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white60),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Şifre en az 8 karakter olmalıdır';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Henüz üye değil misiniz?',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.toNamed('/register');
                            },
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(color: Colors.indigo),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: ElevatedButton(
                        onPressed: login,
                        child: const Text(
                          'Giriş Yap',
                          style: TextStyle(color: Colors.indigo, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
