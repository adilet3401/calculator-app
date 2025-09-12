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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Загружаем данные профиля или создаём их, если документа нет
  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final user = FirebaseAuth.instance.currentUser;

    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // создаём профиль с дефолтными данными
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

  /// Форматируем дату
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

  /// Смена аватара
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

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("Нет данных о пользователе")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0ECE9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color(0xFFF0ECE9),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Профиль',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
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
                  behavior: HitTestBehavior.translucent,
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
            textAlign: TextAlign.center,
          ),
          // if (userData!['age'] != null)
          // Text(
          //   '${userData!['age']} лет',
          //   style: const TextStyle(fontSize: 16, color: Colors.grey),
          //   textAlign: TextAlign.center,
          // ),
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
          // ListTile(
          //   leading: CircleAvatar(
          //     backgroundColor: Colors.orange.shade100,
          //     child: const Icon(Icons.phone, color: Colors.orange),
          //   ),
          //   title: Text(
          //     userData!['phone'] ?? 'Нет номера',
          //     style: const TextStyle(fontSize: 16),
          //   ),
          // ),
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
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: const Text(
              'Выйти',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Действительно выйти с аккаунта?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/');
                        }
                      },
                      child: const Text(
                        'Выйти',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
