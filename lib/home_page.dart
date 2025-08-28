import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final PageController _pageController = PageController();
  int selectedIndex = 0;
  int _pressedIndex = -1; // для эффекта scale при нажатии

  // ===== КАЛЬКУЛЯТОР ====
  String userInput = "";
  String result = "";
  bool isResultDisplayed = false;

  void buttonPressed(String text) {
    setState(() {
      if (text == "C") {
        userInput = "";
        result = "";
        isResultDisplayed = false;
      } else if (text == "⌫") {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
          _calculateResult();
        }
      } else if (text == "=") {
        _calculateResult();
        isResultDisplayed = true;
      } else {
        userInput += text;
        _calculateResult();
        isResultDisplayed = false;
      }
    });
  }

  void _calculateResult() {
    if (userInput.isNotEmpty) {
      try {
        String expr = userInput
            .replaceAll("×", "*")
            .replaceAll("÷", "/")
            .replaceAll(",", ".")
            .replaceAllMapped(
              RegExp(r'(\d+(\.\d+)?)%'),
              (m) => '(${m[1]}/100)',
            );

        // ignore: deprecated_member_use
        Parser p = Parser();
        Expression exp = p.parse(expr);
        ContextModel cm = ContextModel();
        // ignore: deprecated_member_use
        double calculatedResult = exp.evaluate(EvaluationType.REAL, cm);
        result =
            "= ${calculatedResult.toStringAsFixed(calculatedResult.truncateToDouble() == calculatedResult ? 0 : 1)}";
      } catch (e) {
        result = userInput;
      }
    } else {
      result = "";
    }
  }

  // ===== РАСТАМОЖКА =====
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
    _pageController.dispose();
    super.dispose();
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    final buttons = [
      "C",
      "⌫",
      "%",
      "÷",
      "7",
      "8",
      "9",
      "×",
      "4",
      "5",
      "6",
      "-",
      "1",
      "2",
      "3",
      "+",
      ".",
      "0",
      ",",
      "=",
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель переключения (с анимацией)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedTab("Калькулятор", 0),
                const SizedBox(width: 12),
                _buildAnimatedTab("Растаможка", 1),
              ],
            ),
            const SizedBox(height: 10),

            // Контент
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => selectedIndex = index);
                },
                children: [
                  // Калькулятор
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.bottomRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                color: Colors.black,
                                child: FittedBox(
                                  alignment: Alignment.centerRight,
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    userInput,
                                    style: TextStyle(
                                      fontSize: isResultDisplayed ? 25 : 47,
                                      fontWeight: FontWeight.bold,
                                      color: isResultDisplayed
                                          ? Colors.white70
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                result,
                                style: TextStyle(
                                  fontSize: isResultDisplayed ? 47 : 25,
                                  fontWeight: FontWeight.bold,
                                  color: isResultDisplayed
                                      ? Colors.white
                                      : Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: buttons.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                            ),
                        itemBuilder: (context, index) {
                          final btnText = buttons[index];
                          final isOperator = [
                            "÷",
                            "×",
                            "-",
                            "+",
                            "=",
                            "%",
                          ].contains(btnText);

                          return _AnimatedButton(
                            text: btnText,
                            isOperator: isOperator,
                            onPressed: () => buttonPressed(btnText),
                          );
                        },
                      ),
                    ],
                  ),

                  // Растаможка
                  SingleChildScrollView(
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
                                "Доставка/страховка (в базу НДС), сом",
                                freightController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _toggle(
                          title: "Включать сбор в базу НДС",

                          value: includeFeeInVatBase,
                          onChanged: (v) =>
                              setState(() => includeFeeInVatBase = v),
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
                            backgroundColor: const Color(0xff33A1E0),
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
                            fontSize: 17, // ← размер
                            fontWeight: FontWeight.bold, // ← жирный
                            fontFamily:
                                'RobotoMono', // ← пример моноширинного шрифта
                            letterSpacing:
                                1, // ← межбуквенное расстояние (опционально)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==== АНИМИРОВАННЫЕ ТАБЫ ====
  Widget _buildAnimatedTab(String text, int index) {
    final bool isActive = selectedIndex == index;
    final bool isPressed = _pressedIndex == index;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedIndex = index),
      onTapUp: (_) => setState(() => _pressedIndex = -1),
      onTapCancel: () => setState(() => _pressedIndex = -1),
      onTap: () {
        setState(() => selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedScale(
        scale: isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xff33A1E0) : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey[400],
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  // ===== ВСПОМОГАТЕЛЬНЫЕ =====
  Widget _buildField(String label, TextEditingController controller) {
    final isPrice = label == "Стоимость товара";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.\,\s]')),
          if (isPrice) ThousandsFormatter(), // ← только для стоимости товара
        ],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xff33A1E0),
            fontWeight: FontWeight.bold,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff33A1E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff33A1E0), width: 2.5),
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
      activeTrackColor: const Color(0xff33A1E0),
      inactiveThumbColor: Colors.grey[400],
      inactiveTrackColor: Colors.grey[700],
    );
  }
}

// ===================== КНОПКИ КАЛЬКУЛЯТОРА =====================
class _AnimatedButton extends StatefulWidget {
  final String text;
  final bool isOperator;
  final VoidCallback onPressed;

  const _AnimatedButton({
    required this.text,
    required this.isOperator,
    required this.onPressed,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() => _scale = 0.9);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isOperator
                ? const Color(0xff33A1E0)
                : (widget.text == "C" || widget.text == "⌫")
                ? Colors.grey[800]
                : Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: widget.isOperator
                    ? Colors.white
                    : (widget.text == "C" || widget.text == "⌫")
                    ? const Color(0xff33A1E0)
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
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
