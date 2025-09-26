import 'package:calculator/widgets/email_phone_name_edit_line.dart';
import 'package:calculator/widgets/navigate_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sign_in_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  String? errorText;
  bool isLoading = false;

  Future<void> _register() async {
    setState(() {
      errorText = null;
      isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeatPassword = repeatPasswordController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() {
        errorText = 'Введите корректный email';
        isLoading = false;
      });
      return;
    }
    if (password.isEmpty || repeatPassword.isEmpty) {
      setState(() {
        errorText = 'Пожалуйста, заполните все поля';
        isLoading = false;
      });
      return;
    }
    if (password != repeatPassword) {
      setState(() {
        errorText = 'Пароли не совпадают';
        isLoading = false;
      });
      return;
    }
    if (name.isEmpty) {
      setState(() {
        errorText = 'Введите имя';
        isLoading = false;
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        errorText = 'Пароль должен быть не менее 6 символов';
        isLoading = false;
      });
      return;
    }

    try {
      // Создаем пользователя
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // Отправляем письмо для подтверждения
        await user.sendEmailVerification();

        // Записываем данные в Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
        });

        nameController.clear();
        emailController.clear();
        passwordController.clear();
        repeatPasswordController.clear();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('На вашу почту отправлено письмо для подтверждения.'),
            backgroundColor: Colors.orange,
          ),
        );

        // Переходим на SignInPage
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorText = e.code == 'weak-password'
            ? 'Пароль слишком слабый'
            : e.code == 'email-already-in-use'
            ? 'Этот email уже зарегистрирован'
            : e.message ?? 'Ошибка регистрации';
        isLoading = false;
      });
    } on FirebaseException catch (e) {
      setState(() {
        errorText = 'Ошибка сохранения данных: ${e.message}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorText = 'Произошла неизвестная ошибка';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
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
              padding: const EdgeInsets.only(bottom: 60, left: 260),
              child: InkWell(
                child: const Text(
                  'Пропустить',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                    (route) => false,
                  );
                },
              ),
            ),
            UserEmailPasswordline(
              icon: Icons.person,
              hinText: 'Ваше имя',
              controller: nameController,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            UserEmailPasswordline(
              icon: Icons.remove_red_eye_outlined,
              hinText: 'Повтор пароля',
              controller: repeatPasswordController,
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
              text: isLoading ? 'Регистрация...' : 'Зарегистрироваться',
              borderRadius: BorderRadius.circular(24),
              minimumSize: const Size(double.infinity, 56),
              onPressed: isLoading ? null : _register,
            ),
            const SizedBox(height: 20),

            // 🔹 Все тексты под кнопкой оставлены
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'У вас есть зарегистрированный аккаунт?',
                  style: TextStyle(
                    color: Color(0xff878787),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 9),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Вход',
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
            // const ButtonSignInToGoogle(),  // если понадобится
          ],
        ),
      ),
    );
  }
}
