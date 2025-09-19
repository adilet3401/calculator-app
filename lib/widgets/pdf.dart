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
        // 🔥 убираем стандартные поля
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 0,
          marginTop: 0,
          marginLeft: 0,
          marginRight: 0,
        ),
        build: (context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            color: PdfColor.fromInt(0xFF000000), // фон на всю страницу
            padding: pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Заголовок
                pw.Text(
                  'Отчет',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 26,
                    color: PdfColor.fromInt(0xFFFFA500),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Первый блок
                _pdfBox([
                  _pdfRow('Наименование', itemName, font, boldFont),
                  _pdfRow('ТНВЭД код', tnved, font, boldFont),
                  _pdfRow('Имя/Компания', company, font, boldFont),
                  _pdfRow('Страна отправитель', senderCountry, font, boldFont),
                  _pdfRow('Страна получатель', receiverCountry, font, boldFont),
                  _pdfRow('Сохранено', savedAtStr, font, boldFont),
                ]),

                pw.SizedBox(height: 14),

                // Второй блок (Итого, только нужный текст)
                _pdfBox([
                  pw.Text(
                    'Итого',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 18,
                      color: PdfColor.fromInt(0xFFFFA500),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Пошлина: $dutySum сом',
                    style: pw.TextStyle(
                      font: font,
                      color: PdfColor.fromInt(0xFFFFFFFF),
                    ),
                  ),
                  pw.Text(
                    'НДС: $ndsSum сом',
                    style: pw.TextStyle(
                      font: font,
                      color: PdfColor.fromInt(0xFFFFFFFF),
                    ),
                  ),
                  pw.Text(
                    'Таможенный сбор: $feeSum сом',
                    style: pw.TextStyle(
                      font: font,
                      color: PdfColor.fromInt(0xFFFFFFFF),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '----------------------',
                    style: pw.TextStyle(color: PdfColor.fromInt(0xFFFFA500)),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Итого: $resultText сом',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 16,
                      color: PdfColor.fromInt(0xFFFFFFFF),
                    ),
                  ),
                ]),

                pw.SizedBox(height: 14),

                // Третий блок (Стоимость и %)
                _pdfBox([
                  _pdfRow('Стоимость', '$displayPrice сом', font, boldFont),
                  _pdfRow('Пошлина', '$displayDutyPercent %', font, boldFont),
                  _pdfRow('НДС', '$displayNdsPercent %', font, boldFont),
                  _pdfRow(
                    'Таможенный сбор',
                    '$displayFeePercent %',
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

/// Контейнер-блок с рамкой
pw.Widget _pdfBox(List<pw.Widget> children) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0xFF212121),
      border: pw.Border.all(color: PdfColor.fromInt(0xFFFFA500), width: 1),
      borderRadius: pw.BorderRadius.circular(14),
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
              color: PdfColor.fromInt(0xFFBDBDBD),
              fontSize: 14,
            ),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            color: PdfColor.fromInt(0xFFFFFFFF),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
