// pdf_report.dart
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';

class PdfReport {
  static Future<pw.Document> build({
    required String itemName,
    required String tnved,
    required String company,
    required String senderCountry,
    required String receiverCountry,
    required String savedAtStr,

    required String displayPrice,        // "20 000 сом"
    required String displayDutyPercent,  // "10"
    required String displayNdsPercent,   // "12"
    required String displayFeePercent,   // "0.4"

    required String dutySum,             // "2 000 сом"
    required String ndsSum,              // "2 640 сом"
    required String feeSum,              // "80 сом"
    required String resultText,          // "4 720 сом"

    required String currency,            // "сом" / "€" / "$" (символ)
  }) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Nunito-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Nunito-SemiBold.ttf'),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 24,
          marginTop: 24,
          marginLeft: 24,
          marginRight: 24,
        ),
        build: (context) {
          return pw.Container(
            width: double.infinity,
            color: PdfColors.white,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Отчет',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 26,
                    color: PdfColor.fromInt(0xFFFFA500),
                  ),
                ),
                pw.SizedBox(height: 20),

                _pdfBox([
                  _pdfRow('Наименование:', itemName, font, boldFont),
                  _pdfRow('ТНВЭД код:', tnved, font, boldFont),
                  _pdfRow('Имя/Компания:', company, font, boldFont),
                  _pdfRow('Страна отправитель:', senderCountry, font, boldFont),
                  _pdfRow('Страна получатель:', receiverCountry, font, boldFont),
                  _pdfRow('Сохранено:', savedAtStr, font, boldFont),
                ]),

                pw.SizedBox(height: 14),

                _pdfBox([
                  _pdfRow('Стоимость:', displayPrice, font, boldFont),

                  _pdfRow(
                    'Пошлина ($displayDutyPercent %):',
                    dutySum, // уже "2 000 сом"
                    font,
                    boldFont,
                  ),

                  _pdfRow(
                    'НДС ($displayNdsPercent %):',
                    ndsSum,
                    font,
                    boldFont,
                  ),

                  _pdfRow(
                    'Таможенный сбор ($displayFeePercent %):',
                    feeSum,
                    font,
                    boldFont,
                  ),

                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColors.orange, thickness: 1),
                  pw.SizedBox(height: 10),

                  _pdfRow(
                    'Итого:',
                    resultText, // "4 720 сом"
                    font,
                    boldFont,
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }
}

pw.Widget _pdfBox(List<pw.Widget> children) {
  return pw.Container(
    width: double.infinity,
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0xFFF9F9F9),
      border: pw.Border.all(
        color: PdfColor.fromInt(0xFFFFA500),
        width: 1,
      ),
      borderRadius: pw.BorderRadius.circular(12),
    ),
    padding: pw.EdgeInsets.all(14),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    ),
  );
}

pw.Widget _pdfRow(
    String title, String value, pw.Font font, pw.Font boldFont) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              color: PdfColor.fromInt(0xFF444444),
              fontSize: 18,
            ),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            color: PdfColor.fromInt(0xFF222222),
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
}

// модель данных для PDF
class PdfReportData {
  final String itemName;
  final String tnved;
  final String company;
  final String senderCountry;
  final String receiverCountry;
  final String savedAtStr;

  final String displayPrice;
  final String displayDutyPercent;
  final String displayNdsPercent;
  final String displayFeePercent;

  final String dutySum;
  final String ndsSum;
  final String feeSum;
  final String resultText;

  final String currency;

  PdfReportData({
    required this.itemName,
    required this.tnved,
    required this.company,
    required this.senderCountry,
    required this.receiverCountry,
    required this.savedAtStr,
    required this.displayPrice,
    required this.displayDutyPercent,
    required this.displayNdsPercent,
    required this.displayFeePercent,
    required this.dutySum,
    required this.ndsSum,
    required this.feeSum,
    required this.resultText,
    required this.currency,
  });
}
