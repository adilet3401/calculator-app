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
  int selectedIndex = 0; // 0 = калькулятор, 1 = растаможка

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
        // ignore: deprecated_member_use
        Parser p = Parser();
        Expression exp = p.parse(
          userInput
              .replaceAll("×", "*")
              .replaceAll("÷", "/")
              .replaceAll(",", "."),
        );
        ContextModel cm = ContextModel();
        // ignore: deprecated_member_use
        double calculatedResult = exp.evaluate(EvaluationType.REAL, cm);
        // Форматируем результат: убираем ".0", если дробная часть равна 0, и добавляем "="
        result =
            "= ${calculatedResult.toStringAsFixed(calculatedResult.truncateToDouble() == calculatedResult ? 0 : 1)}";
      } catch (e) {
        result = userInput; // При ошибке показываем предыдущий ввод
      }
    } else {
      result = "";
    }
  }

  // ===== РАСТАМОЖКА =====
  final priceController = TextEditingController();
  final dutyController = TextEditingController(text: "10"); // Пошлина, %
  final ndsController = TextEditingController(text: "12"); // НДС, %
  final feeController = TextEditingController(
    text: "0.4",
  ); // Таможенный сбор, %
  final freightController = TextEditingController(
    text: "0",
  ); // Доставка/страховка (входит в базу НДС), сом

  bool includeFeeInVatBase = false; // Включать сбор в базу НДС
  bool roundEachStep = true; // Округлять каждую позицию до целого сома

  String rastamozhkaResult = "";
  final formatter = NumberFormat("#,###", "ru_RU");

  // Удобный парсер чисел: принимает "2 308 600", "2308600", "2,308,600", "2308600.40" и т.п.
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
    final price = _parseNum(priceController.text); // стоимость товара
    final dutyRate = _parseNum(dutyController.text) / 100; // %
    final ndsRate = _parseNum(ndsController.text) / 100; // %
    final feeRate = _parseNum(feeController.text) / 100; // %
    final freight = _parseNum(freightController.text); // сом (в базу НДС)

    // 1) Пошлина
    num duty = price * dutyRate;
    duty = _maybeRound(duty);

    // 2) Сбор
    num fee = price * feeRate; // как правило %, от стоимости/там. стоимости
    fee = _maybeRound(fee);

    // 3) База для НДС: цена + пошлина + доставка/страховка (+ при необходимости сбор)
    num vatBase = price + duty + freight + (includeFeeInVatBase ? fee : 0);
    vatBase = _maybeRound(vatBase);

    // 4) НДС
    num nds = vatBase * ndsRate;
    nds = _maybeRound(nds);

    // 5) Итог к оплате (сумма начислений)
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
      "±",
      "0",
      ",",
      "=",
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель переключения
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab("Калькулятор", 0),
                const SizedBox(width: 20),
                _buildTab("Растаможка", 1),
              ],
            ),
            const SizedBox(height: 10),

            // Контент
            Expanded(
              child: selectedIndex == 0
                  ? Column(
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
                                  color: isResultDisplayed
                                      ? Colors.black
                                      : Colors.black,
                                  child: Text(
                                    userInput,
                                    style: TextStyle(
                                      fontSize: isResultDisplayed ? 25 : 50,
                                      fontWeight: isResultDisplayed
                                          ? FontWeight.bold
                                          : FontWeight.bold,
                                      color: isResultDisplayed
                                          ? Colors.white70
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  result,
                                  style: TextStyle(
                                    fontSize: isResultDisplayed ? 50 : 25,
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

                            return GestureDetector(
                              onTap: () => buttonPressed(btnText),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isOperator
                                      ? Color(0xff33A1E0)
                                      : (btnText == "C" ||
                                            btnText == "⌫" ||
                                            btnText == "±")
                                      ? Colors.grey[800]
                                      : Colors.grey[900],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    btnText,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isOperator
                                          ? Colors.white
                                          : (btnText == "C" ||
                                                btnText == "⌫" ||
                                                btnText == "±")
                                          ? Color(0xff33A1E0)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildField("Стоимость товара", priceController),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  "Пошлина (%)",
                                  dutyController,
                                ),
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
                              backgroundColor: Color(0xff33A1E0),
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
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Подсказка: если у вас в отчёте есть доставка/страховка (CIF), добавьте её в поле выше — она увеличивает базу НДС.",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // табы
  Widget _buildTab(String text, int index) {
    final bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Color(0xff33A1E0) : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: isActive ? Colors.white : Colors.grey[400],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // поле ввода
  Widget _buildField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.\,\s]')),
        ],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xff33A1E0)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff33A1E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
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
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: Color(0xff33A1E0),
      inactiveThumbColor: Colors.grey[400],
      inactiveTrackColor: Colors.grey[700],
    );
  }
}
