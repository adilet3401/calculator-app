import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data();
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
    return Scaffold(
      backgroundColor: Color(0xFFF0ECE9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.orange,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Профиль',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Нет данных пользователя'));
          }
          return Column(
            children: [
              const SizedBox(height: 24),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.orange.shade100,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: data['avatarUrl'] != null
                          ? NetworkImage(data['avatarUrl'])
                          : const AssetImage(
                                  'assets/default-avatar-icon-of-social-media-user-vector.jpg',
                                )
                                as ImageProvider,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange.shade200,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                data['name'] ?? 'Имя не указано',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              if (data['age'] != null)
                Text(
                  '${data['age']} лет',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade300),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(Icons.email, color: Colors.orange),
                ),
                title: Text(
                  data['email'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(Icons.phone, color: Colors.orange),
                ),
                title: Text(
                  data['phone'] ?? 'Нет номера',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(Icons.calendar_today, color: Colors.orange),
                ),
                title: Text(
                  data['createdAt'] != null
                      ? _formatDate(data['createdAt'])
                      : 'Дата регистрации неизвестна',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              // ListTile(
              //   leading: CircleAvatar(
              //     backgroundColor: Colors.orange.shade100,
              //     child: const Icon(Icons.settings, color: Colors.orange),
              //   ),
              //   title: const Text('Settings', style: TextStyle(fontSize: 16)),
              //   trailing: const Icon(Icons.chevron_right),
              //   onTap: () {},
              // ),
              // const Spacer(),
              // Container(
              //   height: 80,
              //   decoration: BoxDecoration(
              //     color: Colors.orange.shade100,
              //     borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}
