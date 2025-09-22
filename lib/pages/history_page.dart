import 'package:calculator/pages/pdf_preview_page.dart';
import 'package:calculator/pages/pdf_report.dart' as pw;
import 'package:calculator/text_styles/text_styles.dart';
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
  List<QueryDocumentSnapshot<Map<String, dynamic>>> historyDocs = [];
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
      historyDocs = snapshot.docs
          .cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
    });
  }

  Future<void> _deleteHistoryItem(String docId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .doc(docId)
        .delete();

    await _loadHistoryFirebase();
  }

  void _confirmDelete(String docId) {
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
              // Иконка корзины
              CircleAvatar(
                radius: 32,
                // ignore: deprecated_member_use
                backgroundColor: Colors.redAccent.withOpacity(0.15),
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Удалить этот расчет?",
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
                        await _deleteHistoryItem(docId);
                      },
                      child: const Text(
                        "Удалить",
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

  void _showDataPage(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    num parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      if (value is String) {
        final s = value.replaceAll(' ', '').replaceAll(',', '.');
        return num.tryParse(s) ?? 0;
      }
      return 0;
    }

    DateTime parseTimestamp(dynamic ts) {
      if (ts == null) return DateTime.now();
      if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
      if (ts is String) {
        try {
          return DateTime.parse(ts);
        } catch (_) {
          final digits = int.tryParse(ts);
          if (digits != null) {
            return DateTime.fromMillisecondsSinceEpoch(digits);
          }
        }
      }
      if (ts is Timestamp) return ts.toDate();
      return DateTime.now();
    }

    String formatResultText(String text) {
      return text.replaceAllMapped(RegExp(r'(\d{4,})'), (match) {
        final raw = match.group(0)!.replaceAll(' ', '');
        final numValue = int.tryParse(raw);
        if (numValue == null) return match.group(0)!;
        return numberFormatter.format(numValue);
      });
    }

    final resultText = formatResultText((data['result'] ?? '').toString());
    final priceNum = parseNum(data['price']);
    final dutyPercentNum = parseNum(data['duty']);
    final ndsPercentNum = parseNum(data['nds']);
    final feePercentNum = parseNum(data['fee']);
    final savedAt = parseTimestamp(data['timestamp']);

    final displayPrice = priceNum == 0 ? '-' : numberFormatter.format(priceNum);
    final displayDutyPercent = dutyPercentNum == 0
        ? '-'
        : dutyPercentNum.toString();
    final displayNdsPercent = ndsPercentNum == 0
        ? '-'
        : ndsPercentNum.toString();
    final displayFeePercent = feePercentNum == 0
        ? '-'
        : feePercentNum.toString();

    final itemName = (data['name'] ?? '').toString();
    final tnved = (data['tnved'] ?? data['tnvEd'] ?? '').toString();
    final company = (data['company'] ?? '').toString();
    final senderCountry = (data['senderCountry'] ?? '').toString();
    final receiverCountry = (data['receiverCountry'] ?? '').toString();
    final savedAtStr = DateFormat('dd.MM.yyyy HH:mm').format(savedAt);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: const Text('Отчет', style: AppTextStyles.appBarTextStyle),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.orange),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border.all(color: Colors.orange, width: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultRow(
                        Icons.label,
                        'Наименование:',
                        itemName.isEmpty ? '-' : itemName,
                      ),
                      _buildResultRow(
                        Icons.numbers,
                        'ТНВЭД код:',
                        tnved.isEmpty ? '-' : tnved,
                      ),
                      _buildResultRow(
                        Icons.business,
                        'Имя/Компания:',
                        company.isEmpty ? '-' : company,
                      ),
                      _buildResultRow(
                        Icons.flag,
                        'Страна отправитель:',
                        senderCountry.isEmpty ? '-' : senderCountry,
                      ),
                      _buildResultRow(
                        Icons.flag,
                        'Страна получатель:',
                        receiverCountry.isEmpty ? '-' : receiverCountry,
                      ),
                      _buildResultRow(
                        Icons.calendar_today,
                        'Сохранено:',
                        savedAtStr,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border.all(color: Colors.orange, width: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (resultText.isEmpty)
                        const Text(
                          'Нет результатов',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else ...[
                        _buildResultRow(
                          Icons.attach_money,
                          'Стоимость:',
                          '$displayPrice сом',
                        ),
                        _buildResultRow(
                          Icons.percent,
                          'Пошлина:',
                          '$displayDutyPercent %',
                        ),
                        _buildResultRow(
                          Icons.percent,
                          'НДС:',
                          '$displayNdsPercent %',
                        ),
                        _buildResultRow(
                          Icons.percent,
                          'Таможенный сбор:',
                          '$displayFeePercent %',
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.orange, thickness: 0.6),
                        const SizedBox(height: 10),
                        _buildResultRow(Icons.calculate, 'Итого:', resultText),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfPreviewPage(
                          reportData: pw.PdfReportData(
                            itemName: itemName,
                            tnved: tnved,
                            company: company,
                            senderCountry: senderCountry,
                            receiverCountry: receiverCountry,
                            savedAtStr: savedAtStr,
                            displayPrice: displayPrice,
                            displayDutyPercent: displayDutyPercent,
                            displayNdsPercent: displayNdsPercent,
                            displayFeePercent: displayFeePercent,
                            resultText: resultText,
                            dutySum: '',
                            ndsSum: '',
                            feeSum: '',
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepOrange, Colors.orangeAccent],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.ios_share_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Отправить',
                            style: AppTextStyles.buttonTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.resultTextStyle.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
          Text(value, style: AppTextStyles.resultTextStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 👈 чтобы фон был под стеклянным навбаром
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('История расчетов', style: AppTextStyles.appBarTextStyle),
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
          child: historyDocs.isEmpty
              ? ListView(
                  children: [
                    SizedBox(height: 250),
                    Icon(Icons.history, color: Colors.grey, size: 48),
                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        'История пуста',
                        style: AppTextStyles.appBarTextStyle.copyWith(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  itemCount: historyDocs.length,
                  itemBuilder: (context, index) {
                    final doc = historyDocs[index];
                    final data = doc.data();
                    final displayTitle =
                        (data['name'] ?? '').toString().isNotEmpty
                        ? data['name'].toString()
                        : doc.id;
                    return Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: Colors.orange,
                          width: 0.8,
                        ),
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
                          displayTitle,
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
                        onTap: () => _showDataPage(doc),
                        onLongPress: () => _confirmDelete(doc.id),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
