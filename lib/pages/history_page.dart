import 'package:calculator/pages/pdf_preview_page.dart';
import 'package:calculator/pages/pdf_report.dart' as pw;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// import 'package:pdf/widgets.dart' as pw;

// import 'pdf_report.dart'; // файл, где находится PdfReport

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
              Navigator.of(context).pop();
              await _deleteHistoryItem(docId);
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

  void _showDataPage(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    num _parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      if (value is String) {
        final s = value.replaceAll(' ', '').replaceAll(',', '.');
        return num.tryParse(s) ?? 0;
      }
      return 0;
    }

    DateTime _parseTimestamp(dynamic ts) {
      if (ts == null) return DateTime.now();
      if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
      if (ts is String) {
        try {
          return DateTime.parse(ts);
        } catch (_) {
          final digits = int.tryParse(ts);
          if (digits != null)
            return DateTime.fromMillisecondsSinceEpoch(digits);
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
    final priceNum = _parseNum(data['price']);
    final dutyPercentNum = _parseNum(data['duty']);
    final ndsPercentNum = _parseNum(data['nds']);
    final feePercentNum = _parseNum(data['fee']);
    final savedAt = _parseTimestamp(data['timestamp']);

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
            title: const Text(
              'Отчет',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.orange),
            actions: [
              // IconButton(
              //   icon: const Icon(Icons.share, color: Colors.orange),
              //   onPressed: () async {
              //     final pdf = await pw.PdfReport.build(
              //       itemName: itemName,
              //       tnved: tnved,
              //       company: company,
              //       senderCountry: senderCountry,
              //       receiverCountry: receiverCountry,
              //       savedAtStr: savedAtStr,
              //       displayPrice: displayPrice,
              //       displayDutyPercent: displayDutyPercent,
              //       displayNdsPercent: displayNdsPercent,
              //       displayFeePercent: displayFeePercent,
              //       resultText: resultText,
              //       dutySum: '',
              //       ndsSum: '',
              //       feeSum: '',
              //     );
              //     final output = await getTemporaryDirectory();
              //     final file = File('${output.path}/report.pdf');
              //     await file.writeAsBytes(await pdf.save());
              //     await Share.shareXFiles([
              //       XFile(file.path),
              //     ], text: 'PDF отчет по расчету');
              //   },
              // ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border.all(color: Colors.orange, width: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultRow(
                        Icons.label,
                        'Наименование',
                        itemName.isEmpty ? '-' : itemName,
                      ),
                      _buildResultRow(
                        Icons.numbers,
                        'ТНВЭД код',
                        tnved.isEmpty ? '-' : tnved,
                      ),
                      _buildResultRow(
                        Icons.business,
                        'Имя/Компания',
                        company.isEmpty ? '-' : company,
                      ),
                      _buildResultRow(
                        Icons.flag,
                        'Страна отправитель',
                        senderCountry.isEmpty ? '-' : senderCountry,
                      ),
                      _buildResultRow(
                        Icons.flag,
                        'Страна получатель',
                        receiverCountry.isEmpty ? '-' : receiverCountry,
                      ),
                      _buildResultRow(
                        Icons.calendar_today,
                        'Сохранено',
                        savedAtStr,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border.all(color: Colors.orange, width: 0.6),
                    borderRadius: BorderRadius.circular(12),
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
                        // const Divider(color: Colors.orange, thickness: 0.5),
                        _buildResultRow(
                          Icons.attach_money,
                          'Стоимость',
                          '$displayPrice сом',
                        ),
                        _buildResultRow(
                          Icons.percent,
                          'Пошлина',
                          '$displayDutyPercent %',
                        ),
                        _buildResultRow(
                          Icons.percent,
                          'НДС',
                          '$displayNdsPercent %',
                        ),
                        _buildResultRow(
                          Icons.percent,
                          'Таможенный сбор',
                          '$displayFeePercent %',
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.orange, thickness: 0.6),
                        SizedBox(height: 10),
                        _buildResultRow(Icons.calculate, 'Итого', resultText),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  onPressed: () {
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.picture_as_pdf_rounded, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Отправить',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
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
          child: historyDocs.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 300),
                    Center(
                      child: Text(
                        'История пуста',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
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
