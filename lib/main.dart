import 'dart:convert';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/login_screen.dart';
import 'package:connect_card/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();
Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  //Если будем добавлять еще языки, то с настроек вытягивать надо будет
  await initializeDateFormatting('ru_RU', null);
  Intl.defaultLocale = 'ru_RU';

  final user = await _checkAuth();

  runApp(MainApp(user: user,));
}

Future<User?> _checkAuth() async {
  final accessToken = await storage.read(key: 'token');
  if (accessToken == null) return null;

  final expirationDate = JwtDecoder.getExpirationDate(accessToken);
  final now = DateTime.now();
  final isNearExpiry = expirationDate.isBefore(now.add(Duration(minutes: 1)));

  if (!isNearExpiry) {
    print("Valid");
    return await _loadInfo(accessToken);
  }
  print("Not valid");
  final refreshToken = await storage.read(key: 'refresh_token');
  if (refreshToken == null) {
    await storage.deleteAll();
    return null;
  }

  final newToken = await _tradeRefreshToken(refreshToken);
  if (newToken != null) {
    return await _loadInfo(newToken);
  } else {
    await storage.deleteAll();
    return null;
  }
}

Future<String?> _tradeRefreshToken(String refreshToken) async {
  final url = Uri.parse('${dotenv.env['BASE_URL']}/auth/refresh');

  try {
    final response = await http.post(
      url,
      body: refreshToken,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      await storage.write(key: 'token', value: jsonData['access_token']);
      await storage.write(key: 'refresh_token', value: jsonData['refresh_token']);
      return jsonData['access_token'];
    }
    return null;
  } catch (e) {
    print("Error refreshing token: $e");
    return null;
  }
}

Future<User?> _loadInfo(String token) async {
  final url = Uri.parse('${dotenv.env['BASE_URL']}/auth/current_user');
  try{
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    }
    return null;
  }catch (e) {
    print('Error loading user info: $e');
    return null;
  }
}

class MainApp extends StatelessWidget {
  final User? user;
  const MainApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: user != null ? WelcomeScreen(userName: user!.name) : LoginScreen(),
      // home: QrScanTest(),
      theme: ThemeData.dark(),
    );
  }
}
