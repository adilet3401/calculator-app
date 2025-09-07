import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.orange,
          onPressed: () {
            // Navigator.pop(context);
          },
        ),
        title: Text('Профиль', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
