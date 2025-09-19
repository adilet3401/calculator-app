import 'package:calculator/sign-log_in%20pages/register_page_in_guest.dart';
import 'package:calculator/sign-log_in%20pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Выйти из аккаунта?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
                );
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
  }

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

  @override
  Widget build(BuildContext context) {
    if (isFirstLoad) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (isGuest) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'Профиль',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
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
                    color: Colors.black,
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
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Нет данных о пользователе",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // --- Темная тема профиль ---
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        backgroundColor: Colors.grey[900],
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
                backgroundColor: Colors.grey.shade900,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: userData!['avatarUrl'] != null
                      ? NetworkImage(userData!['avatarUrl'])
                      : const AssetImage(
                              'assets/images/default-avatar-icon-of-social-media-user-vector.jpg',
                            )
                            as ImageProvider,
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade800),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade900,
              child: const Icon(Icons.email, color: Colors.orange),
            ),
            title: Text(
              userData!['email'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade900,
              child: const Icon(Icons.calendar_today, color: Colors.orange),
            ),
            title: Text(
              userData!['createdAt'] != null
                  ? _formatDate(userData!['createdAt'])
                  : 'Дата регистрации неизвестна',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.redAccent.shade700,
                child: const Icon(Icons.logout, color: Colors.white),
              ),
              title: const Text(
                "Выйти",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent,
                ),
              ),
              onTap: _confirmSignOut,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // ignore: deprecated_member_use
              tileColor: Colors.redAccent.withOpacity(0.12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }
}
