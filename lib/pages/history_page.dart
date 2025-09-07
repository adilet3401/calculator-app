import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> historyNames = [];
  Map<String, dynamic>? selectedData;

  @override
  void initState() {
    super.initState();
    _loadHistoryFirebase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistoryFirebase();
  }

  Future<void> _loadHistoryFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('timestamp', descending: true) // сортировка по времени
        .get();

    setState(() {
      historyNames = snapshot.docs.map((doc) => doc.id).toList();
      selectedData = null;
    });
  }

  // Публичный метод для обновления истории
  void refreshHistory() {
    _loadHistoryFirebase();
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
    } else {
      setState(() {
        selectedData = null;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные для этого кода не найдены')),
      );
    }
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
            onPressed: refreshHistory,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.orange,
          onRefresh: () async {
            await _loadHistoryFirebase();
          },
          child: historyNames.isEmpty
              ? ListView(
                  // Чтобы RefreshIndicator работал даже при пустом списке
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
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: historyNames.length,
                        itemBuilder: (context, index) {
                          final name = historyNames[index];
                          return Card(
                            color: Colors.grey[900],
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
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
                              onTap: () => _viewDataFirebase(name),
                            ),
                          );
                        },
                      ),
                    ),
                    if (selectedData != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 0, right: 32),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedData!['result'] ?? 'Нет данных',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'RobotoMono',
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(color: Colors.orange.shade200),
                                    const SizedBox(height: 8),
                                    _infoRow(
                                      'Стоимость',
                                      selectedData!['price'],
                                    ),
                                    _infoRow(
                                      'Пошлина (%)',
                                      selectedData!['duty'],
                                    ),
                                    _infoRow('НДС (%)', selectedData!['nds']),
                                    _infoRow('Сбор (%)', selectedData!['fee']),
                                    _infoRow(
                                      'Доставка/страховка',
                                      selectedData!['freight'],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedData = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (selectedData == null && historyNames.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Выберите расчет для просмотра подробностей',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
