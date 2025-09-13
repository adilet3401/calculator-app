import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

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

  void buttonPressed(String text) {
    setState(() {
      if (text == "C") {
        userInput = "";
        result = "";
        isResultDisplayed = false;
        topFontSize = 47;
        bottomFontSize = 25;
      } else if (text == "⌫") {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
          _calculateResult();
        }
      } else if (text == "=") {
        _calculateResult();
        isResultDisplayed = true;
        _animateFontSizes();
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // userInput c плавной анимацией
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: topFontSize,
                        end: topFontSize,
                      ),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          userInput,
                          style: TextStyle(
                            fontSize: value,
                            fontWeight: FontWeight.bold,
                            color: isResultDisplayed
                                ? Colors.white70
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                    // result c плавной анимацией
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: bottomFontSize,
                        end: bottomFontSize,
                      ),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          result,
                          style: TextStyle(
                            fontSize: value,
                            fontWeight: FontWeight.bold,
                            color: isResultDisplayed
                                ? Colors.white
                                : Colors.white60,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
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

                return _AnimatedButton(
                  text: btnText,
                  isOperator: isOperator,
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

  void _animateTap() async {
    setState(() => _scale = 0.92);
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
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isOperator
                ? Colors.orange
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
                    ? Colors.orange
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
