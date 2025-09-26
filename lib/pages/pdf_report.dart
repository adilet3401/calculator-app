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
    required String displayPrice,
    required String displayDutyPercent, // % (строкой)
    required String displayNdsPercent, // % (строкой)
    required String displayFeePercent, // % (строкой)
    required String resultText, // сумма итоговая
    required String dutySum, // сумма пошлины
    required String ndsSum, // сумма НДС
    required String feeSum, // сумма сбора
    required String currency,
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
            color: PdfColors.white, // ✅ белый фон страницы
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Заголовок
                pw.Text(
                  'Отчет',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 26,
                    color: PdfColor.fromInt(0xFFFFA500), // оранжевый акцент
                  ),
                ),
                pw.SizedBox(height: 20),

                // Первый блок
                _pdfBox([
                  _pdfRow('Наименование:', itemName, font, boldFont),
                  _pdfRow('ТНВЭД код:', tnved, font, boldFont),
                  _pdfRow('Имя/Компания:', company, font, boldFont),
                  _pdfRow('Страна отправитель:', senderCountry, font, boldFont),
                  _pdfRow(
                    'Страна получатель:',
                    receiverCountry,
                    font,
                    boldFont,
                  ),
                  _pdfRow('Сохранено:', savedAtStr, font, boldFont),
                ]),

                pw.SizedBox(height: 14),

                // Второй блок (Итого)
                _pdfBox([
                  _pdfRow(
                    'Стоимость:',
                    '$displayPrice $currency',
                    font,
                    boldFont,
                  ),
                  _pdfRow('Пошлина:', '$displayDutyPercent %', font, boldFont),
                  _pdfRow('НДС:', '$displayNdsPercent %', font, boldFont),
                  _pdfRow(
                    'Таможенный сбор:',
                    '$displayFeePercent %',
                    font,
                    boldFont,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColors.orange, thickness: 1),
                  pw.SizedBox(height: 10),
                  _pdfRow('Итого:', resultText, font, boldFont),
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

/// Контейнер-блок с рамкой (светлый стиль)
pw.Widget _pdfBox(List<pw.Widget> children) {
  return pw.Container(
    width: double.infinity,
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0xFFF9F9F9), // ✅ светло-серый фон блока
      border: pw.Border.all(
        color: PdfColor.fromInt(0xFFFFA500),
        width: 1,
      ), // оранжевая рамка
      borderRadius: pw.BorderRadius.circular(12),
    ),
    padding: pw.EdgeInsets.all(14),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    ),
  );
}

/// Одна строка отчета (заголовок + значение)
pw.Widget _pdfRow(String title, String value, pw.Font font, pw.Font boldFont) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              color: PdfColor.fromInt(0xFF444444), // тёмно-серый текст
              fontSize: 18,
            ),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            color: PdfColor.fromInt(0xFF222222), // почти черный
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
}

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
  final String resultText;
  final String dutySum;
  final String ndsSum;
  final String feeSum;
  final String currency; // 👈 добавляем сюда валюту

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
    required this.resultText,
    required this.dutySum,
    required this.ndsSum,
    required this.feeSum,
    required this.currency,
  });
}
