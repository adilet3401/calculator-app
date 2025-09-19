import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RastamozhkaPage extends StatefulWidget {
  const RastamozhkaPage({super.key});

  @override
  State<RastamozhkaPage> createState() => _RastamozhkaPageState();
}

class _RastamozhkaPageState extends State<RastamozhkaPage> {
  final priceController = TextEditingController();
  final dutyController = TextEditingController(text: "10");
  final ndsController = TextEditingController(text: "12");
  final feeController = TextEditingController(text: "0.4");
  final freightController = TextEditingController(text: "0");

  bool includeFeeInVatBase = false;
  bool roundEachStep = true;
  bool hasCalculated = false;
  bool isSaving = false;
  String rastamozhkaResult = "";

  Future<void> _showSaveBottomSheet() async {
    final nameController = TextEditingController();
    final tnvEdController = TextEditingController();
    final companyController = TextEditingController();
    final senderCountryController = TextEditingController(text: "Китай");
    final receiverCountryController = TextEditingController(
      text: "Кыргызстан, Бишкек",
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetField(
                Icons.label,
                "Наименование товара",
                nameController,
              ),
              _buildBottomSheetField(
                Icons.numbers,
                "ТНВЭД код",
                tnvEdController,
              ),
              _buildBottomSheetField(
                Icons.business,
                "Имя / Компания",
                companyController,
              ),
              _buildBottomSheetField(
                Icons.flag,
                "Страна отправитель",
                senderCountryController,
              ),
              _buildBottomSheetField(
                Icons.flag,
                "Страна получатель",
                receiverCountryController,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await saveToHistoryFirebase(
                    name: nameController.text,
                    tnvEd: tnvEdController.text,
                    company: companyController.text,
                    route: '',
                    senderCountry: senderCountryController.text,
                    receiverCountry: receiverCountryController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  maximumSize: const Size(150, 100),
                  minimumSize: const Size(100, 50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Сохранить",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveToHistoryFirebase({
    required String name,
    required String tnvEd,
    required String company,
    required String route,
    required String senderCountry,
    required String receiverCountry,
  }) async {
    setState(() {
      isSaving = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ошибка авторизации')));
      setState(() {
        isSaving = false;
      });
      return;
    }

    final data = {
      'price': priceController.text,
      'duty': dutyController.text,
      'nds': ndsController.text,
      'fee': feeController.text,
      'freight': freightController.text,
      'includeFeeInVatBase': includeFeeInVatBase,
      'roundEachStep': roundEachStep,
      'result': rastamozhkaResult,
      'name': name,
      'tnved': tnvEd,
      'company': company,
      'route': route,
      'senderCountry': senderCountry,
      'receiverCountry': receiverCountry,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('history')
          .add(data);

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Сохранено успешно!')));
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
      setState(() {
        isSaving = false;
      });
    }
  }

  void calculateRastamozhka() {
    final priceText = priceController.text.replaceAll(' ', '');
    if (priceText.isEmpty) {
      setState(() {
        rastamozhkaResult = "Введите стоимость товара!";
        hasCalculated = true;
      });
      return;
    }

    final price = int.tryParse(priceText) ?? 0;
    final dutyPercent = double.tryParse(dutyController.text) ?? 0;
    final ndsPercent = double.tryParse(ndsController.text) ?? 0;
    final feePercent = double.tryParse(feeController.text) ?? 0;
    final freight = double.tryParse(freightController.text) ?? 0;

    int dutySum = (price * dutyPercent / 100).round();
    int feeSum = (price * feePercent / 100).round();
    double vatBase = price + dutySum + freight;
    if (includeFeeInVatBase) vatBase += feeSum;
    int ndsSum = (vatBase * ndsPercent / 100).round();
    int total = dutySum + ndsSum + feeSum;

    setState(() {
      rastamozhkaResult =
          "Пошлина: $dutySum сом\nНДС: $ndsSum сом\nТаможенный сбор: $feeSum сом\n----------------------\nИтого: $total сом";
      hasCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Растаможка",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField("Стоимость товара", priceController),
              Row(
                children: [
                  Expanded(child: _buildField("Пошлина (%)", dutyController)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField("НДС (%)", ndsController)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildField("Сбор (%)", feeController)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      "Доставка/страховка (сом)",
                      freightController,
                    ),
                  ),
                ],
              ),
              _toggle(
                title: "Включать сбор в базу НДС",
                value: includeFeeInVatBase,
                onChanged: (v) => setState(() => includeFeeInVatBase = v),
              ),
              _toggle(
                title: "Округлять каждую позицию (до 1 сома)",
                value: roundEachStep,
                onChanged: (v) => setState(() => roundEachStep = v),
              ),
              ElevatedButton(
                onPressed: calculateRastamozhka,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(90, 50),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  maximumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  "Рассчитать",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (hasCalculated) ...[
                const SizedBox(height: 16),
                if (!isGuest)
                  ElevatedButton(
                    onPressed: _showSaveBottomSheet,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(90, 50),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      maximumSize: const Size(double.infinity, 56),
                    ),
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Сохранить",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )
                else
                  const Text(
                    "Вы зашли как гость. Чтобы сохранять историю — зарегистрируйтесь",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(20),
                  color: Colors.black,
                  child: Text(
                    rastamozhkaResult,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetField(
    IconData icon,
    String hint,
    TextEditingController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.orange),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.orange),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    final isPrice = label == "Стоимость товара";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.\,\s]')),
          if (isPrice) ThousandsFormatter(),
        ],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.orange),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _toggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeTrackColor: Colors.orange,
      inactiveTrackColor: Colors.grey[700],
    );
  }
}

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '').replaceAll(',', '.');
    if (text.isEmpty) return newValue.copyWith(text: '');
    final numValue = int.tryParse(text);
    if (numValue == null) return newValue;
    final newText = _formatWithSpaces(numValue.toString());
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String _formatWithSpaces(String value) {
    final buffer = StringBuffer();
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(' ');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}
