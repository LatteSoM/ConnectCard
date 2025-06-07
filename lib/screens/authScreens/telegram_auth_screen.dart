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
  final _formKey = GlobalKey<FormState>();

  final baseUrl = dotenv.env['BASE_URL']!;

  void _showCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFE5F3FF),
        title: Text("Введите код", style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 5,
          decoration: InputDecoration(
            hintText: "Код из SMS",
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Отмена", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              _authorize();
            },
            child: Text("Авторизоваться", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _getCode() async{

    final codeUrl = Uri.parse('$baseUrl/request_code');
    print(codeUrl);

    try{
      final response = await http.post(
        codeUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone" : _phoneController.text,
        }),
      );

      if(response.statusCode == 200){
        final responseData = jsonDecode(response.body);
        SnackbarHelper.showMessage(context, "Код подтверждения отправлен");
      }else{
        final error = jsonDecode(response.body);
        print("Ошибка ${error['error']}");
        SnackbarHelper.showMessage(context, "Произошла ошибка. Пожалуйста, попробуйте еще раз", isSuccess: false);
      }
    }catch (e){
      print("Ошибка сети ${e}");
      SnackbarHelper.showMessage(context, "Извините, произошла ошибка", isSuccess: false);
    }
  }

  Future<void> _authorize() async {
    final authUrl = Uri.parse('$baseUrl/verify_code');

    try{
      final response = await http.post(
        authUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone" : _phoneController.text,
          "code": _codeController.text,
          "password": "",
        }),
      );

      if(response.statusCode == 200){
        final Map<String, dynamic> data = jsonDecode(response.body);
        final userJson = data['user'];
        final user = UserModel.fromJson(userJson);
        SnackbarHelper.showMessage(context, "Вы успешно авторизовались");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
          (Route<dynamic> route) => false,
          );


      }else{
        final error = jsonDecode(response.body);
        print("Ошибка ${error['error']}");
        SnackbarHelper.showMessage(context, "Произошла ошибка. Пожалуйста, попробуйте еще раз", isSuccess: false);
      }
    }catch (e){
      print("Ошибка сети ${e}");
      SnackbarHelper.showMessage(context, "Извините, произошла ошибка", isSuccess: false);
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0088CC), Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      String text = newValue.text.replaceAll(RegExp(r'\D'), '');
                      if (text.length > 11) {
                        text = text.substring(0, 11);
                      }
                      String formatted = "+7 " + text.substring(1);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    })
                  ],
                  validator: (value) {
                    if (value == null || value.length < 12) {
                      return "Введите корректный номер";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Номер телефона",
                    labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0088CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _getCode();
                      _showCodeDialog();
                    }
                  },
                  child: Text("Получить код"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}