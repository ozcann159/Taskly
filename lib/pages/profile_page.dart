import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('E-posta'),
                subtitle: Text(user?.email ?? ''),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Tema'),
                trailing: Switch(
                  value: Get.isDarkMode,
                  onChanged: (value) {
                    Get.changeThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Çıkış Yap'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.offAllNamed('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}