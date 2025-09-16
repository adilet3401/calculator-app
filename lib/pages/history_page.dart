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
    });
  }

  Future<Map<String, dynamic>?> _getHistoryData(String name) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .doc(name)
        .get();

    return doc.exists ? doc.data() : null;
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
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Удалить этот расчет?',
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
              Navigator.of(context).pop(); // Закрываем диалог
              await _deleteHistoryItem(name); // Удаляем один раз
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

  void _showDataBottomSheet(String name) async {
    final data = await _getHistoryData(name);
    if (data == null || !mounted) return;

    num _parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      if (value is String) {
        return num.tryParse(value.replaceAll(' ', '')) ?? 0;
      }
      return 0;
    }

    String formatResultText(String text) {
      // Форматировать числа длиной 4 и более: 1000 -> 1 000
      return text.replaceAllMapped(RegExp(r'(\d{4,})'), (match) {
        final raw = match.group(0)!.replaceAll(' ', '');
        final numValue = int.tryParse(raw);
        if (numValue == null) return match.group(0)!;
        // Форматировать с пробелом после каждой группы из 3 цифр
        final str = numValue.toString();
        final buffer = StringBuffer();
        for (int i = 0; i < str.length; i++) {
          if (i != 0 && (str.length - i) % 3 == 0) buffer.write(' ');
          buffer.write(str[i]);
        }
        return buffer.toString();
      });
    }

    final resultText = formatResultText(data["result"]?.toString() ?? "");
    final price = numberFormatter.format(_parseNum(data["price"]));
    final dutyPercent = numberFormatter.format(_parseNum(data["duty"]));
    final vatPercent = numberFormatter.format(_parseNum(data["nds"]));
    final feePercent = numberFormatter.format(_parseNum(data["fee"]));
    final shipping = numberFormatter.format(_parseNum(data["freight"]));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AnimatedBottomSheet(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('', style: TextStyle(fontSize: 18)),
                    const Text(
                      'Отчет',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.orange),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  resultText,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Divider(color: Colors.orange, thickness: 1, height: 24),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Стоимость: $price',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Пошлина: $dutyPercent%',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'НДС: $vatPercent%',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Сбор: $feePercent%',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Доставка/страховка: $shipping',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                        onTap: () => _showDataBottomSheet(name),
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

/// Виджет анимации выезда снизу
class _AnimatedBottomSheet extends StatefulWidget {
  final Widget child;
  const _AnimatedBottomSheet({required this.child});

  @override
  State<_AnimatedBottomSheet> createState() => _AnimatedBottomSheetState();
}

class _AnimatedBottomSheetState extends State<_AnimatedBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.reverse(); // плавное исчезновение при закрытии
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
