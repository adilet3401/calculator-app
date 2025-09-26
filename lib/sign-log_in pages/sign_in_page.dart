import 'package:calculator/pages/home_page.dart';
import 'package:calculator/sign-log_in%20pages/register_page.dart';
import 'package:calculator/widgets/email_phone_name_edit_line.dart';
import 'package:calculator/widgets/navigate_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// 🔑 Вход через Email + Password
  Future<void> _signIn() async {
    if (isLoading) return;
    if (mounted) {
      setState(() {
        errorText = null;
        isLoading = true;
      });
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      if (mounted) {
        setState(() {
          errorText = 'Введите корректный email';
          isLoading = false;
        });
      }
      return;
    }
    if (password.isEmpty) {
      if (mounted) {
        setState(() {
          errorText = 'Введите пароль';
          isLoading = false;
        });
      }
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        // 📩 если почта не подтверждена
        await user.sendEmailVerification(); // повторная отправка
        if (mounted) {
          setState(() {
            errorText = 'Подтвердите email. Ссылка отправлена повторно.';
            isLoading = false;
          });
        }
        await FirebaseAuth.instance.signOut(); // выходим, пока не подтвердит
        return;
      }

      // ✅ сохраняем вход
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
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
      if (mounted) {
        setState(() {
          errorText = message;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          errorText = 'Произошла неизвестная ошибка';
          isLoading = false;
        });
      }
    }
  }

  /// 🔑 Анонимный вход (гость)
  Future<void> _signInAnonymously() async {
    if (isLoading) return;
    if (mounted) setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();

      // ✅ сохраняем вход
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          errorText = 'Не удалось войти как гость';
          isLoading = false;
        });
      }
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
            /// 🔘 Кнопка "Пропустить" (гостевой вход)
            Padding(
              padding: const EdgeInsets.only(bottom: 60, left: 260),
              child: InkWell(
                onTap: isLoading ? null : _signInAnonymously,
                child: const Text(
                  'Пропустить',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            /// 📧 Поле Email
            UserEmailPasswordline(
              icon: Icons.mail_outline_rounded,
              hinText: 'Ваша электронная почта',
              controller: emailController,
            ),
            const SizedBox(height: 20),

            /// 🔒 Поле Пароль
            UserEmailPasswordline(
              icon: Icons.remove_red_eye_outlined,
              hinText: 'Пароль',
              controller: passwordController,
              obscureText: true,
            ),

            /// ⚠️ Ошибка
            if (errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],

            const SizedBox(height: 40),

            /// 🔘 Кнопка "Войти"
            NavigateButton(
              text: isLoading ? 'Вход...' : 'Вход',
              borderRadius: BorderRadius.circular(24),
              minimumSize: const Size(double.infinity, 56),
              onPressed: isLoading ? null : _signIn,
              isLoading: isLoading,
            ),

            const SizedBox(height: 20),

            /// 📌 Ссылка "Регистрация"
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
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
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

            /// 🔘 Разделитель "Или"
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

            /// 🔑 Вход через Google (если нужно)
            // const ButtonSignInToGoogle(),
          ],
        ),
      ),
    );
  }
}
