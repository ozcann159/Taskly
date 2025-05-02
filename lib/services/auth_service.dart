import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> signUp(String email, String password, String name) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await createUserDocument(userCredential, name); 
  } catch (e) {
    
  }
}

Future<void> createUserDocument(UserCredential userCredential, String name) async {
  final userId = userCredential.user?.uid;
  if (userId != null) {
    await FirebaseFirestore.instance.collection('User').doc(userId).set({
      'name': name,
      'createdAt': Timestamp.now(),
    });
  }
}