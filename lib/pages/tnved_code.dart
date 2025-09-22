import 'package:calculator/text_styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TnvedPage extends StatefulWidget {
  const TnvedPage({super.key});

  @override
  State<TnvedPage> createState() => _TnvedPageState();
}

class _TnvedPageState extends State<TnvedPage>
    with AutomaticKeepAliveClientMixin {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // 👈 прозрачный фон WebView
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false);
            // 🔽 фиксируем метатег viewport для нормального отображения
            controller.runJavaScript(
              'document.querySelector("meta[name=viewport]").setAttribute("content", "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no");',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse('https://tnved.info'));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBody: true, // 👈 фон продолжается под стеклянный навбар
      backgroundColor: Colors.black, // 👈 общий фон
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text(
          'Поиск по ТН ВЭД',
          style: AppTextStyles.appBarTextStyle.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false, // 👈 чтобы навбар оставался стеклянным
            child: WebViewWidget(controller: controller),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
        ],
      ),
    );
  }
}
