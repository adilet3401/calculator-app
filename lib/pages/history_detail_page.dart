

// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart' as pw;

// class HistoryDetailPage extends StatelessWidget {
//   final Map<String, dynamic> data;
//   const HistoryDetailPage({super.key, required this.data});

//   Future<void> _generateAndSharePdf(BuildContext context) async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text(data['result'] ?? 'Нет данных', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 16),
//             pw.Divider(),
//             pw.Text('Стоимость: ${data['price'] ?? '-'}'),
//             pw.Text('Пошлина (%): ${data['duty'] ?? '-'}'),
//             pw.Text('НДС (%): ${data['nds'] ?? '-'}'),
//             pw.Text('Сбор (%): ${data['fee'] ?? '-'}'),
//             pw.Text('Доставка/страховка: ${data['freight'] ?? '-'}'),
//           ],
//         ),
//       ),
//     );

//     await Printing.sharePdf(bytes: await pdf.save(), filename: 'calculation.pdf');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         title: const Text(
//           'Детали расчета',
//           style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 data['result'] ?? 'Нет данных',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'RobotoMono',
//                   letterSpacing: 1,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Divider(color: Colors.orange.shade200),
//               const SizedBox(height: 8),
//               _infoRow('Стоимость', data['price']),
//               _infoRow('Пошлина (%)', data['duty']),
//               _infoRow('НДС (%)', data['nds']),
//               _infoRow('Сбор (%)', data['fee']),
//               _infoRow('Доставка/страховка', data['freight']),
//               const Spacer(),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
//                   label: const Text(
//                     'Отправить PDF',
//                     style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                   onPressed: () => _generateAndSharePdf(context),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(
//               color: Colors.orange,
//               fontWeight: FontWeight.w500,
//               fontSize: 17,
//             ),
//           ),
//           Text(
//             value?.toString() ?? '-',
//             style: const TextStyle(color: Colors.white, fontSize: 17),
//           ),
//         ],
//       ),
//     );
//   }
// }