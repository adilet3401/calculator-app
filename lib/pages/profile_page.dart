import 'package:calculator/sign-log_in%20pages/register_page_in_guest.dart';
import 'package:calculator/sign-log_in%20pages/sign_in_page.dart';
import 'package:calculator/text_styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade900, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.6),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка выхода
              CircleAvatar(
                radius: 32,
                // ignore: deprecated_member_use
                backgroundColor: Colors.orange.withOpacity(0.15),
                child: const Icon(Icons.logout, color: Colors.orange, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                "Выйти из аккаунта?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Отмена",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // 🔥 Выход из Firebase
                        await FirebaseAuth.instance.signOut();

                        // 🔥 Очистка SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('isLoggedIn');

                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text(
                        "Выйти",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          // title: Text(
          //   'Профиль',
          //   style: AppTextStyles.buttonTextStyle.copyWith(
          //     color: Colors.red,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
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

    // --- Новый дизайн ---
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Профиль', style: AppTextStyles.appBarTextStyle),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ).copyWith(bottom: 80), // место под навбар
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 54,
                backgroundColor: Colors.grey.shade800,
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
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                userData!['name'] ?? 'Имя не указано',
                style: AppTextStyles.userNameTextStyle,
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey.shade800),
            _buildInfoCard(Icons.email, userData!['email'] ?? ''),
            _buildInfoCard(
              Icons.calendar_today,
              userData!['createdAt'] != null
                  ? _formatDate(userData!['createdAt'])
                  : 'Дата регистрации неизвестна',
            ),
            const SizedBox(height: 24),
            // 🔥 Кнопка выхода
            GestureDetector(
              onTap: _confirmSignOut,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent, width: 1),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text(
                        "Выйти",
                        style: AppTextStyles.buttonTextStyle.copyWith(
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.orange.withOpacity(0.6), width: 0.7),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.infoCardTextStyle)),
        ],
      ),
    );
  }
}
