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
