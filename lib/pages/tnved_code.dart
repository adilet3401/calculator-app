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
  bool isLoading = true; // Переменная для отслеживания состояния загрузки

  @override
  bool get wantKeepAlive => true; // Сохраняем состояние страницы

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Можно обновлять прогресс загрузки, если нужно
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true; // Показываем индикатор загрузки
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false; // Скрываем индикатор загрузки
            });
            // Инжектим метатег viewport после загрузки страницы
            controller.runJavaScript(
              'document.querySelector("meta[name=viewport]").setAttribute("content", "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no");',
            );
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://tnved.info'));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Необходимо для AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Поиск по ТН ВЭД',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller), // Веб-виджет
          if (isLoading) // Показываем индикатор, если isLoading = true
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
