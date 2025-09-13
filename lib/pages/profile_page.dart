import 'package:calculator/sign-log_in%20pages/register_page_in_guest.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = false;
  bool isFirstLoad = true;
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (user.isAnonymous) {
      // Если пользователь гость — не грузим Firestore
      setState(() {
        isGuest = true;
        isFirstLoad = false;
      });
    } else {
      await _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final user = FirebaseAuth.instance.currentUser;

    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        "name": user?.displayName ?? "Без имени",
        "email": user?.email ?? "",
        "phone": user?.phoneNumber ?? "Нет номера",
        "createdAt": FieldValue.serverTimestamp(),
        "avatarUrl": null,
      });
      final newDoc = await docRef.get();
      setState(() {
        userData = newDoc.data();
        isFirstLoad = false;
      });
    } else {
      setState(() {
        userData = doc.data();
        isFirstLoad = false;
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return 'Некорректная дата';
    }
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _changeAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      isLoading = true;
    });

    final file = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance.ref().child('avatars/$uid.jpg');
    await storageRef.putFile(file);
    final avatarUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'avatarUrl': avatarUrl,
    });

    await _loadUserData();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstLoad) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isGuest) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0ECE9),
        appBar: AppBar(
          title: const Text('Профиль'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                "Вы зашли как гость,\nхотите зарегистрироваться?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPageInGuest(),
                    ),
                  );
                },
                child: const Text(
                  "Зарегистрироваться",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("Нет данных о пользователе")),
      );
    }

    // --- Обычный профиль как у вас ---
    return Scaffold(
      backgroundColor: const Color(0xFFF0ECE9),
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 54,
                backgroundColor: Colors.orange.shade100,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: userData!['avatarUrl'] != null
                      ? NetworkImage(userData!['avatarUrl'])
                      : const AssetImage(
                              'assets/default-avatar-icon-of-social-media-user-vector.jpg',
                            )
                            as ImageProvider,
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: isLoading ? null : _changeAvatar,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.orange.shade200,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userData!['name'] ?? 'Имя не указано',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade300),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.email, color: Colors.orange),
            ),
            title: Text(
              userData!['email'] ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.calendar_today, color: Colors.orange),
            ),
            title: Text(
              userData!['createdAt'] != null
                  ? _formatDate(userData!['createdAt'])
                  : 'Дата регистрации неизвестна',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
