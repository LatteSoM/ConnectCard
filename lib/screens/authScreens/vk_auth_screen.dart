import 'dart:convert';
import 'dart:math';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class VkAuthScreen extends StatefulWidget {
  const VkAuthScreen({super.key});

  @override
  State<VkAuthScreen> createState() => _VkAuthScreenState();
}

class _VkAuthScreenState extends State<VkAuthScreen> {
  late final WebViewController _webViewController;

  late final String _codeVerifier;
  late final String _state;

  final clientId = dotenv.env['VK_CLIENT_ID'];
  final redirectUri = dotenv.env['VK_REDIRECT_URI'];

  final url = "${dotenv.env['BASE_URL']!}/auth/vk/exchange";

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }


  void _initializeAuth() {

    _codeVerifier = _generateCodeVerifier();
    _state = _generateRandomString(32);

    final codeChallenge = _generateCodeChallenge(_codeVerifier);

    final authUrl = Uri.https('id.vk.com', '/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'email,phone',
      'state': _state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    }).toString();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: _handleNavigationRequest,
      ))
      ..loadRequest(Uri.parse(authUrl));
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final url = Uri.parse(request.url);

    if (url.toString().startsWith(redirectUri as Pattern)) {
      final code = url.queryParameters['code'];
      final deviceId = url.queryParameters['device_id'];
      final state = url.queryParameters['state'];

      if (state != _state) {
        print('State mismatch, возможная подмена запроса!');
        return NavigationDecision.prevent;
      }

      if (code != null && deviceId != null) {

        exchangeCode(code: code, deviceId: deviceId, codeVerifier: _codeVerifier);
      }
      return NavigationDecision.prevent; 
    }

    return NavigationDecision.navigate;
  }

  Future<void> exchangeCode({
    required String code,
    required String deviceId,
    required String codeVerifier,
  }) async {

    final payload = {
      'code': code,
      'device_id': deviceId,
      'code_verifier': codeVerifier,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        SnackbarHelper.showMessage(context, "Успешная авторизация");
        Navigator.pop(context);
      } else {
        SnackbarHelper.showMessage(context, "Извините, произошла ошибка", isSuccess: false);
        print('Ошибка обмена кода: ${response.body}');
      }
    } catch (e) {
      SnackbarHelper.showMessage(context, "Извините, произошла ошибка сети", isSuccess: false);
      print('Ошибка сети: $e');
    }
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(64, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  String _generateCodeChallenge(String codeVerifier) {
    final bytes = ascii.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  String _generateRandomString(int length) {
    const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход через VK ID')),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
