import 'package:calculator/pages/home_page.dart';
import 'package:calculator/sign-log_in%20pages/register_page.dart';
import 'package:calculator/widgets/sign_in_to_google.dart';
import 'package:calculator/widgets/email_phone_name_edit_line.dart';
import 'package:calculator/widgets/navigate_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorText;
  bool isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      errorText = null;
      isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() {
        errorText = 'Введите корректный email';
        isLoading = false;
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        errorText = 'Введите пароль';
        isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Пользователь с таким email не найден';
          break;
        case 'wrong-password':
          message = 'Неверный пароль';
          break;
        case 'invalid-email':
          message = 'Некорректный email';
          break;
        case 'user-disabled':
          message = 'Аккаунт отключён';
          break;
        case 'too-many-requests':
          message = 'Слишком много попыток входа. Попробуйте позже.';
          break;
        default:
          message = 'Ошибка входа';
      }
      setState(() {
        errorText = message;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorText = 'Произошла неизвестная ошибка';
        isLoading = false;
      });
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      setState(() {
        errorText = 'Не удалось войти как гость';
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 22, right: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 60, left: 260),
              child: InkWell(
                onTap: _signInAnonymously,
                child: Text(
                  'Пропустить',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            UserEmailPasswordline(
              icon: Icons.mail_outline_rounded,
              hinText: 'Ваша электронная почта',
              controller: emailController,
            ),
            const SizedBox(height: 20),
            UserEmailPasswordline(
              icon: Icons.remove_red_eye_outlined,
              hinText: 'Пароль',
              controller: passwordController,
              obscureText: true,
            ),
            if (errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 40),
            NavigateButton(
              text: isLoading ? 'Вход...' : 'Вход',
              borderRadius: BorderRadius.circular(24),
              minimumSize: const Size(double.infinity, 56),
              onPressed: isLoading ? null : _signIn,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Нету зарегистрированного аккаунта?',
                  style: TextStyle(
                    color: Color(0xff878787),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 9),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text(
                    'Регистрация',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.orange.shade200,
                    thickness: 1,
                    indent: 40,
                    endIndent: 10,
                  ),
                ),
                const Text(
                  'Или',
                  style: TextStyle(
                    color: Color(0xff878787),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.orange.shade200,
                    thickness: 1,
                    indent: 10,
                    endIndent: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const ButtonSignInToGoogle(),
          ],
        ),
      ),
    );
  }
}
