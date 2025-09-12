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
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final dutyController = TextEditingController(text: "10");
  final ndsController = TextEditingController(text: "12");
  final feeController = TextEditingController(text: "0.4");
  final freightController = TextEditingController(text: "0");

  bool includeFeeInVatBase = false;
  bool roundEachStep = true;
  bool hasCalculated = false;
  bool isSaveEnabled = false;
  bool isSaving = false;

  String rastamozhkaResult = "";
  String saveButtonText = "Сохранить";

  Future<void> saveToHistoryFirebase() async {
    setState(() {
      isSaving = true;
      saveButtonText = "Сохранение...";
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final name = nameController.text.trim();

    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ошибка авторизации')));
      setState(() {
        isSaving = false;
        saveButtonText = "Сохранить";
      });
      return;
    }

    if (name.isEmpty || !RegExp(r'^\d+$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите числовой код в поле "Наименование"'),
        ),
      );
      setState(() {
        isSaving = false;
        saveButtonText = "Сохранить";
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
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('history')
          .doc(name)
          .set(data);

      // ignore: use_build_context_synchronously
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text(
      //       'Успешно сохранено',
      //       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //     ),
      //     backgroundColor: Colors.green,
      //   ),
      // );

      setState(() {
        saveButtonText = "Сохранено";
        isSaving = false;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          saveButtonText = "Сохранить";
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        saveButtonText = "Сохранить";
        isSaving = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      final text = nameController.text.trim();
      setState(() {
        isSaveEnabled = text.isNotEmpty && RegExp(r'^\d+$').hasMatch(text);
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    dutyController.dispose();
    ndsController.dispose();
    feeController.dispose();
    freightController.dispose();
    super.dispose();
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
    if (roundEachStep) dutySum = dutySum.round();

    int feeSum = (price * feePercent / 100).round();
    if (roundEachStep) feeSum = feeSum.round();

    double vatBase = price + dutySum + freight;
    if (includeFeeInVatBase) vatBase += feeSum;

    int ndsSum = (vatBase * ndsPercent / 100).round();
    if (roundEachStep) ndsSum = ndsSum.round();

    int total = dutySum + ndsSum + feeSum;

    setState(() {
      rastamozhkaResult =
          "Пошлина: $dutySum сом\nНДС: $ndsSum сом\nТаможенный сбор: $feeSum сом\n----------------------\nИтого: $total сом";
      saveButtonText = "Сохранить";
      hasCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField("Наименование", nameController, isName: true),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: calculateRastamozhka,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Рассчитать",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // --- Кнопка "Сохранить" + результат ---
              if (hasCalculated) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (isSaveEnabled && !isSaving) {
                      saveToHistoryFirebase();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (saveButtonText == "Сохранено")
                        ? Colors.green
                        : (!isSaveEnabled || isSaving)
                        ? Colors.grey
                        : Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              saveButtonText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (saveButtonText == "Сохранено") ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check, color: Colors.white),
                            ],
                          ],
                        ),
                ),
                if (rastamozhkaResult.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      rastamozhkaResult,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoMono',
                        letterSpacing: 1,
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isName = false,
  }) {
    final isPrice = label == "Стоимость товара";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          if (isName) FilteringTextInputFormatter.digitsOnly,
          if (!isName)
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.\,\s]')),
          if (isPrice) ThousandsFormatter(),
        ],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange, width: 2.5),
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
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: Colors.orange,
      inactiveThumbColor: Colors.grey,
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
