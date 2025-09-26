import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:calculator/pages/pdf_report.dart' as pw; // ваш PdfReport

class PdfPreviewPage extends StatelessWidget {
  final pw.PdfReportData reportData; // данные для отчета

  const PdfPreviewPage({super.key, required this.reportData});

  Future<File> _generatePdfFile() async {
    final pdf = await pw.PdfReport.build(
      itemName: reportData.itemName,
      tnved: reportData.tnved,
      company: reportData.company,
      senderCountry: reportData.senderCountry,
      receiverCountry: reportData.receiverCountry,
      savedAtStr: reportData.savedAtStr,
      displayPrice: reportData.displayPrice,
      displayDutyPercent: reportData.displayDutyPercent,
      displayNdsPercent: reportData.displayNdsPercent,
      displayFeePercent: reportData.displayFeePercent,
      resultText: reportData.resultText,
      dutySum: reportData.dutySum,
      ndsSum: reportData.ndsSum,
      feeSum: reportData.feeSum,
      currency: reportData.currency,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _generatePdfFile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final file = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'PDF отчет',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.orange),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded, color: Colors.orange),
                onPressed: () async {
                  // ignore: deprecated_member_use
                  await Share.shareXFiles([
                    XFile(file.path),
                  ], text: 'PDF отчет');
                },
              ),
            ],
          ),
          body: PdfPreview(build: (format) async => await file.readAsBytes()),
        );
      },
    );
  }
}
