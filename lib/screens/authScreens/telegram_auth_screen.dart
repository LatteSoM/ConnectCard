import 'dart:convert';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/profile_screen.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TelegramAuthScreen extends StatefulWidget {
  const TelegramAuthScreen({super.key});

  @override
  State<TelegramAuthScreen> createState() => _TelegramAuthScreenState();
}

class _TelegramAuthScreenState extends State<TelegramAuthScreen> {
  final TextEditingController _phoneController = TextEditingController(text: "+7 ");
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool codeSent = false;
  bool showPasswordField = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final baseUrl = dotenv.env['BASE_URL']!;

  Future<void> requestCode(String phone) async{
    setState(() {
      isLoading = true;
    });
    final response = await http.post(
      Uri.parse('$baseUrl/request_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    setState(() {
      isLoading = false;
    });

    if(response.statusCode == 200){
      setState(() {
        codeSent = true;
      });
    }else{
      SnackbarHelper.showMessage(context, "Ошибка при отправке кода", isSuccess: false);
    }
  }

  Future<void> verifyCode(String phone, String code) async{
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('$baseUrl/verify_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );

    setState(() {
      isLoading = false;
    });

    if(response.statusCode == 200){
      final data = jsonDecode(response.body);

      if(data['need_password'] == true){
        setState(() {
          showPasswordField = true;
        });
      }else{
        final userJson = data['user'];
        // final user = UserModel.fromJson(userJson);
        SnackbarHelper.showMessage(context, "Вы успешно авторизовались");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
          (Route<dynamic> route) => false,
          );
      }
    }else{
      SnackbarHelper.showMessage(context, "Неверный код", isSuccess: false);
    }
  }

  Future<void> completeSignIn(String phone, String password) async{
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('$baseUrl/complete_sign_in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    setState(() {
      isLoading = false;
    });

    if(response.statusCode == 200){
      final Map<String, dynamic> data = jsonDecode(response.body);
      final userJson = data['user'];
      // final user = UserModel.fromJson(userJson);
      SnackbarHelper.showMessage(context, "Вы успешно авторизовались");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
          (Route<dynamic> route) => false,
          );
    }else{
      SnackbarHelper.showMessage(context, "Неверный пароль", isSuccess: false);
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Вход в Telegram"),
        centerTitle: true,
        backgroundColor: Color(0xFF0088CC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if(!codeSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Номер телефона'),
              ),
              const SizedBox(height: 16,),
              ElevatedButton(
                onPressed: isLoading
                ? null
                : () => requestCode(_phoneController.text.trim()),
                child: const Text('Получить код'),
              ),
            ] else ...[
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Код подтверждения'),
              ),
              if(showPasswordField) ...[
                const SizedBox(height: 12,),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                ),
              ],
              const SizedBox(height: 16,),
              ElevatedButton(
                onPressed: isLoading
                ? null
                : () {
                  final phone = _phoneController.text.trim();
                  final code = _codeController.text.trim();

                  if(showPasswordField){
                    final password = _passwordController.text.trim();
                    completeSignIn(phone, password);
                  }else{
                    verifyCode(phone, code);
                  }
                }, child: const Text('Войти'),
              ),
            ],
            if(isLoading) const Padding(
              padding: EdgeInsets.only(top: 20),
              child: CircularProgressIndicator(),
            ),
          ],
        ),),
    );
  }
}