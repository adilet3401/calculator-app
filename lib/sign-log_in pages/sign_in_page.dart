import 'package:calculator/pages/home_page.dart';
import 'package:calculator/sign-log_in%20pages/sign_in_to_google.dart';
import 'package:calculator/widgets/email_phone_name_edit_line.dart';
import 'package:calculator/widgets/navigate_button.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage(HomePage homePage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 22, right: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserEmailPasswordline(
              icon: Icons.phone,
              hinText: 'Сиздин номериңиз',
            ),
            SizedBox(height: 20),
            UserEmailPasswordline(icon: Icons.email, hinText: 'Сыр сөз'),
            SizedBox(height: 40),
            NavigateButton(
              text: 'Кирүү',
              borderRadius: BorderRadius.circular(24),
              minimumSize: Size(double.infinity, 56),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInPage(HomePage()),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Катталган аккаунтуңуз барбы?',
                  style: TextStyle(
                    color: Color(0xff878787),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 15),
                InkWell(
                  onTap: () {
                    // context.go('/login');
                  },
                  child: Text(
                    'Бул жерден кириңиз',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
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
                Text(
                  'Же',
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
            SizedBox(height: 30),
            ButtonSignInToGoogle(),
          ],
        ),
      ),
    );
  }
}
