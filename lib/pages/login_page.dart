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
  bool _isLoading = false;
  bool _obscurePassword = true;

  void login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        Get.offNamed('/todo-page'); // Başarılı girişten sonra yönlendirme
      } on FirebaseAuthException catch (e) {
        Get.snackbar(
          'Hata',
          e.message ?? 'Bir hata oluştu',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        Get.snackbar(
          'Hata',
          'Bir hata oluştu',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Hoş Geldiniz",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Görevlerinizi yönetmek için giriş yapın",
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "E-posta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'ornek@email.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.error),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'E-posta adresi gerekli';
                          }
                          if (!value.contains('@')) {
                            return 'Geçerli bir e-posta adresi girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Şifre",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: colorScheme.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.error),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre gerekli';
                          }
                          if (value.length < 8) {
                            return 'Şifre en az 8 karakter olmalıdır';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isLoading
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                  : const Text(
                                    'Giriş Yap',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Henüz hesabınız yok mu?',
                            style: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.toNamed('/register');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                            ),
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
