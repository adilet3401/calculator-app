import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String userInput = "";
  String result = "";
  bool isResultDisplayed = false;

  double topFontSize = 47;
  double bottomFontSize = 25;

  final numberFormatter = NumberFormat.decimalPattern('ru');

  void buttonPressed(String text) {
    setState(() {
      if (text == "C") {
        userInput = "";
        result = "";
        isResultDisplayed = false;
        topFontSize = 47;
        bottomFontSize = 25;
        HapticFeedback.mediumImpact();
      } else if (text == "⌫") {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
          _calculateResult();
          HapticFeedback.lightImpact();
        }
      } else if (text == "=") {
        _calculateResult();
        isResultDisplayed = true;
        _animateFontSizes();
        HapticFeedback.heavyImpact();
      } else {
        final operators = ["+", "-", "×", "÷"];

        if (operators.contains(text)) {
          if (userInput.isEmpty) return;

          if (operators.contains(userInput.characters.last)) {
            userInput = userInput.substring(0, userInput.length - 1) + text;
          } else {
            userInput += text;
          }
        } else {
          userInput += text;
        }

        _calculateResult();
        isResultDisplayed = false;
        topFontSize = 47;
        bottomFontSize = 25;
      }
    });
  }

  void _animateFontSizes() {
    setState(() {
      topFontSize = 25;
      bottomFontSize = 47;
    });
  }

  void _calculateResult() {
    if (userInput.isNotEmpty) {
      try {
        String expr = userInput
            .replaceAll("×", "*")
            .replaceAll("÷", "/")
            .replaceAll(",", ".")
            .replaceAll(" ", "") // убираем пробелы перед вычислением
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

        // Форматирование результата
        String formatted =
            calculatedResult.truncateToDouble() == calculatedResult
            ? numberFormatter.format(calculatedResult.toInt())
            : numberFormatter.format(
                double.parse(calculatedResult.toStringAsFixed(2)),
              );

        result = "= $formatted";
      } catch (e) {
        result = userInput;
      }
    } else {
      result = "";
    }
  }

  /// Функция форматирования чисел во вводе
  String _formatInput(String input) {
    return input.splitMapJoin(
      RegExp(r'(\d+\.?\d*)'),
      onMatch: (m) {
        final numStr = m[0]!;
        final numValue = double.tryParse(numStr.replaceAll(' ', ''));
        if (numValue == null) return numStr;
        if (numValue == numValue.truncateToDouble()) {
          return numberFormatter.format(numValue.toInt());
        } else {
          return numberFormatter.format(numValue);
        }
      },
      onNonMatch: (n) => n,
    );
  }

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
            // Дисплей калькулятора
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: topFontSize,
                        fontWeight: FontWeight.bold,
                        color: isResultDisplayed
                            ? Colors.white54
                            : Colors.white,
                      ),
                      child: Text(_formatInput(userInput)),
                    ),
                    const SizedBox(height: 10),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: bottomFontSize,
                        fontWeight: FontWeight.bold,
                        color: isResultDisplayed
                            ? Colors.orangeAccent
                            : Colors.white70,
                      ),
                      child: Text(result),
                    ),
                  ],
                ),
              ),
            ),
            // Кнопки
            GridView.builder(
              shrinkWrap: true,
              itemCount: buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                final isAction = ["C", "⌫"].contains(btnText);

                return _AnimatedButton(
                  text: btnText,
                  isOperator: isOperator,
                  isAction: isAction,
                  onPressed: () => buttonPressed(btnText),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String text;
  final bool isOperator;
  final bool isAction;
  final VoidCallback onPressed;

  const _AnimatedButton({
    required this.text,
    required this.isOperator,
    required this.isAction,
    required this.onPressed,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  double _scale = 1.0;

  void _animateTap() async {
    setState(() => _scale = 0.9);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _scale = 1.0);
  }

  void _onTap() {
    _animateTap();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isEqual = widget.text == "=";

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: isEqual
                ? const LinearGradient(
                    colors: [Colors.deepOrange, Colors.orangeAccent],
                  )
                : widget.isOperator
                ? const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  )
                : null,
            color: widget.isAction
                ? Colors.grey[850]
                : widget.isOperator
                ? null
                : Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (isEqual || widget.isOperator)
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isEqual
                    ? Colors.white
                    : widget.isOperator
                    ? Colors.white
                    : widget.isAction
                    ? Colors.orangeAccent
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
