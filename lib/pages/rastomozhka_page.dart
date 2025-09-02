import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

  String rastamozhkaResult = "";
  final formatter = NumberFormat("#,###", "ru_RU");

  double _parseNum(String raw) {
    final s = raw
        .trim()
        .replaceAll(" ", "")
        .replaceAll("\u00A0", "")
        .replaceAll(",", ".");
    return double.tryParse(s) ?? 0.0;
  }

  num _maybeRound(num v) => roundEachStep ? v.round() : v;

  void calculateRastamozhka() {
    final price = _parseNum(priceController.text);
    final dutyRate = _parseNum(dutyController.text) / 100;
    final ndsRate = _parseNum(ndsController.text) / 100;
    final feeRate = _parseNum(feeController.text) / 100;
    final freight = _parseNum(freightController.text);

    num duty = price * dutyRate;
    duty = _maybeRound(duty);

    num fee = price * feeRate;
    fee = _maybeRound(fee);

    num vatBase = price + duty + freight + (includeFeeInVatBase ? fee : 0);
    vatBase = _maybeRound(vatBase);

    num nds = vatBase * ndsRate;
    nds = _maybeRound(nds);

    num total = duty + nds + fee;
    total = _maybeRound(total);

    setState(() {
      rastamozhkaResult =
          """
Пошлина: ${formatter.format(duty)} сом
НДС: ${formatter.format(nds)} сом
Таможенный сбор: ${formatter.format(fee)} сом
---------------------
Итого: ${formatter.format(total)} сом
""";
    });
  }

  @override
  void dispose() {
    priceController.dispose();
    dutyController.dispose();
    ndsController.dispose();
    feeController.dispose();
    freightController.dispose();
    super.dispose();
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
              _buildField("Стоимость товара", priceController),
              Row(
                children: [
                  Expanded(
                    child: _buildField("Пошлина (%)", dutyController),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField("НДС (%)", ndsController),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField("Сбор (%)", feeController),
                  ),
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
              const SizedBox(height: 16),
              Text(
                rastamozhkaResult,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoMono',
                  letterSpacing: 1,
                ),
              ),
            ],
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
