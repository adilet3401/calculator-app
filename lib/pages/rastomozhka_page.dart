import 'package:calculator/text_styles/text_styles.dart';
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
  bool isSaved = false;
  String rastamozhkaResult = "";

  /// Валюта (код)
  String selectedCurrency = "KGS";

  /// Символы валют
  final Map<String, String> currencySymbols = {
    "KGS": "сом",
    "EUR": "€",
    "USD": "\$",
  };

  void calculateRastamozhka() {
    final priceText = priceController.text.replaceAll(' ', '');
    if (priceText.isEmpty || priceText == "0") {
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

    // расчёт
    int dutySum = (price * dutyPercent / 100).round();
    int feeSum = (price * feePercent / 100).round();

    double vatBase = price + dutySum + freight;
    if (includeFeeInVatBase) vatBase += feeSum;
    int ndsSum = (vatBase * ndsPercent / 100).round();

    int total = dutySum + ndsSum + feeSum;

    final currSymbol = currencySymbols[selectedCurrency] ?? "";

    setState(() {
      rastamozhkaResult =
          "Пошлина: ${_formatNumber(dutySum)} $currSymbol\n"
          "НДС: ${_formatNumber(ndsSum)} $currSymbol\n"
          "Таможенный сбор: ${_formatNumber(feeSum)} $currSymbol\n"
          "----------------------\n"
          "Итого: ${_formatNumber(total)} $currSymbol";
      hasCalculated = true;
    });
  }

  Future<void> saveToHistoryFirebase({
    required String name,
    required String tnvEd,
    required String company,
    required String senderCountry,
    required String receiverCountry,
  }) async {
    setState(() {
      isSaving = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        isSaving = false;
      });
      return;
    }

    final data = {
      'price': priceController.text,           // исходная стоимость
      'duty': dutyController.text,             // %
      'nds': ndsController.text,               // %
      'fee': feeController.text,               // %
      'freight': freightController.text,       // доставка
      'includeFeeInVatBase': includeFeeInVatBase,
      'roundEachStep': roundEachStep,
      'result': rastamozhkaResult,             // 💥 форматированный текст с суммами и валютой
      'currency': selectedCurrency,            // 💥 сохраняем код валюты: "KGS"/"EUR"/"USD"

      'name': name,
      'tnved': tnvEd,
      'company': company,
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

      if (!mounted) return;
      setState(() {
        isSaving = false;
        isSaved = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isSaved = false;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> _showSaveBottomSheet() async {
    final nameController = TextEditingController();
    final tnvEdController = TextEditingController();
    final companyController = TextEditingController();
    final senderCountryController = TextEditingController(text: "Китай");
    final receiverCountryController =
        TextEditingController(text: "Кыргызстан, Бишкек");

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheetField(
                  Icons.folder,
                  "Наименование товара",
                  nameController,
                ),
                _buildBottomSheetField(
                  Icons.tag,
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
                _buildGradientButton(
                  text: "Сохранить",
                  colors: [Colors.green.shade700, Colors.greenAccent],
                  onTap: () async {
                    Navigator.pop(context);
                    await saveToHistoryFirebase(
                      name: nameController.text,
                      tnvEd: tnvEdController.text,
                      company: companyController.text,
                      senderCountry: senderCountryController.text,
                      receiverCountry: receiverCountryController.text,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
    final String rawPrice = priceController.text.replaceAll(" ", "");
    final bool disableSaveButton =
        rawPrice.isEmpty ||
        rawPrice == "0" ||
        rastamozhkaResult == "Введите стоимость товара!";

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Растаможка", style: AppTextStyles.appBarTextStyle),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: kBottomNavigationBarHeight + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCardField(
                        "Стоимость товара",
                        priceController,
                        isPrice: true,
                        icon: Icons.attach_money,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCardField(
                              "Пошлина (%)",
                              dutyController,
                              icon: Icons.percent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCardField(
                              "НДС (%)",
                              ndsController,
                              icon: Icons.percent,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCardField(
                              "Сбор (%)",
                              feeController,
                              icon: Icons.percent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCardField(
                              "Доставка/страховка",
                              freightController,
                              icon: Icons.attach_money,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // выбор валюты
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orangeAccent,
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCurrency,
                            dropdownColor: Colors.grey[900],
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.orangeAccent,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            items: currencySymbols.keys.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Text(
                                      value,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      currencySymbols[value]!,
                                      style: const TextStyle(
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedCurrency = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      _toggle(
                        title: "Включать сбор в базу НДС",
                        value: includeFeeInVatBase,
                        onChanged: (v) =>
                            setState(() => includeFeeInVatBase = v),
                      ),
                      _toggle(
                        title: "Округлять каждую позицию (до 1)",
                        value: roundEachStep,
                        onChanged: (v) => setState(() => roundEachStep = v),
                      ),

                      const SizedBox(height: 20),
                      _buildGradientButton(
                        text: "Рассчитать",
                        colors: [Colors.deepOrange, Colors.orangeAccent],
                        onTap: calculateRastamozhka,
                      ),

                      if (hasCalculated) ...[
                        const SizedBox(height: 16),
                        if (!isGuest)
                          _buildGradientButton(
                            text: "Сохранить",
                            colors: disableSaveButton
                                ? [Colors.grey, Colors.grey]
                                : [Colors.green.shade700, Colors.greenAccent],
                            onTap: disableSaveButton
                                ? null
                                : _showSaveBottomSheet,
                            isLoading: isSaving,
                            isSaved: isSaved,
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Вы зашли как гость. Чтобы сохранять историю — зарегистрируйтесь",
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orangeAccent,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            rastamozhkaResult,
                            style: AppTextStyles.buttonTextStyle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // поля ввода
  Widget _buildCardField(
    String label,
    TextEditingController controller, {
    bool isPrice = false,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          if (isPrice) ThousandsFormatter(),
        ],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.orangeAccent) : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelText: label,
          labelStyle: AppTextStyles.cardTextStyle,
          border: InputBorder.none,
        ),
      ),
    );
  }

  // кнопка
  Widget _buildGradientButton({
    required String text,
    required List<Color> colors,
    required VoidCallback? onTap,
    bool isLoading = false,
    bool isSaved = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(colors: colors),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : AnimatedScale(
                  scale: isSaved ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: isSaved
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Сохранено",
                              style: AppTextStyles.buttonTextStyle,
                            ),
                          ],
                        )
                      : Text(text, style: AppTextStyles.buttonTextStyle),
                ),
        ),
      ),
    );
  }

  // свитч
  Widget _toggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.buttonTextStyle),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.orangeAccent,
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.grey[800],
    );
  }

  // поля в bottom sheet
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
          prefixIcon: Icon(icon, color: Colors.orangeAccent),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.orangeAccent),
          filled: true,
          fillColor: Colors.grey[900],
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orangeAccent),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(' ');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}

/// форматтер цены с пробелами
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(' ', '');
    if (text.isEmpty) return newValue.copyWith(text: '');

    final number = int.tryParse(text);
    if (number == null) return oldValue;

    final newText = _formatWithSpaces(number.toString());

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
