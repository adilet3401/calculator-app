import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> historyNames = [];
  Map<String, dynamic>? selectedData;
  final numberFormatter = NumberFormat.decimalPattern('ru');

  @override
  void initState() {
    super.initState();
    _loadHistoryFirebase();
  }

  Future<void> _loadHistoryFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      historyNames = snapshot.docs.map((doc) => doc.id).toList();
      selectedData = null;
    });
  }

  Future<void> _viewDataFirebase(String name) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .doc(name)
        .get();

    if (doc.exists) {
      setState(() {
        selectedData = doc.data();
      });
    }
  }

  Future<void> _deleteHistoryItem(String name) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .doc(name)
        .delete();

    await _loadHistoryFirebase();
  }

  void _confirmDelete(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // backgroundColor: Colors.grey.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Удалить этот расчет?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await _deleteHistoryItem(name);
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text(
              'Удалить',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'История расчетов',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: _loadHistoryFirebase,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.orange,
          onRefresh: _loadHistoryFirebase,
          child: historyNames.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'История пуста',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: historyNames.length,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final name = historyNames[index];
                    return Card(
                      color: Colors.grey[900],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.orange,
                          size: 18,
                        ),
                        onTap: () async {
                          await _viewDataFirebase(name);
                          if (selectedData != null) {
                            // здесь можно вызвать ваш bottom sheet
                          }
                        },
                        onLongPress: () => _confirmDelete(name),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
