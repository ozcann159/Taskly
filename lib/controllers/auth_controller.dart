import 'package:get/get.dart';

class AuthController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var passwordConfirm = ''.obs;

  bool validateEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-zA-Z]+").hasMatch(email);
  }

  bool validatePassword(String password) {
    return password.length >= 8;
  }

  bool validateForm() {
    return validateEmail(email.value) &&
           validatePassword(password.value) &&
           password.value == passwordConfirm.value;
  }

  void signUp() {
    if (validateForm()) {
      // İşlemler yapılabilir
    } else {
      // Hata mesajları gösterilebilir
    }
  }
}
