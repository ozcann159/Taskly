import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isProcessing = false;

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isProcessing = true; // İşlem başlıyor
      });
      try {
        // Firebase Authentication ile kullanıcı kaydı
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Kullanıcı Firestore'a eklenecek
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'name': _nameController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Get.offAllNamed('/todo-page'); // Kayıt sonrası ana sayfaya yönlendirme
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        if (e.code == 'email-already-in-use') {
          errorMessage =
              'Bu e-posta adresi zaten başka bir hesap tarafından kullanılıyor.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Geçersiz e-posta adresi girdiniz.';
        } else if (e.code == 'operation-not-allowed') {
          errorMessage = 'E-posta ile kayıt olma özelliği devre dışı.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Girdiğiniz şifre çok zayıf.';
        } else {
          errorMessage = 'Bir hata oluştu: ${e.message}';
        }

        // Hata mesajını göster
        Get.snackbar('Hata', errorMessage, backgroundColor: Colors.red);
      } finally {
        setState(() {
          _isProcessing = false; // İşlem tamamlandı
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d2630),
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
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
                "Giriş yapabilmek için kayıt olun.",
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
                      style: const TextStyle(color: Colors.white), // Yazı rengi
                      controller: _nameController,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.account_circle,
                            color: Colors.white,
                          ),
                          labelText: 'Ad Soyad',
                          labelStyle: const TextStyle(color: Colors.white60),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white60),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ad soyad gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      style: const TextStyle(color: Colors.white), // Yazı rengi
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                        labelText: 'E-posta',
                        labelStyle: const TextStyle(color: Colors.white60),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white60),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      style: const TextStyle(color: Colors.white), // Yazı rengi
                      controller: _passwordController,
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
                          return 'Şifre en az 8 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : _register, // Butonu pasif yapma
                        child: _isProcessing
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                    color: Colors.indigo, fontSize: 18),
                              ),
                      ),
                    ),
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
