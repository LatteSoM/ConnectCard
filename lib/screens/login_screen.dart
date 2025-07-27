import 'dart:convert';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/authScreens/telegram_auth_screen.dart';
import 'package:connect_card/screens/authScreens/vk_auth_screen.dart';
import 'package:connect_card/screens/profile_screen.dart';
import 'package:connect_card/screens/register_screen.dart';
import 'package:connect_card/screens/welcome_screen.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{

  final baseUrl = dotenv.env['BASE_URL'];
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  Future<void> _extractToken(String token) async{
    final url = Uri.parse('$baseUrl/auth/current_user');
    try{
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        }
      );
      if(response.statusCode == 200){
        final storage = FlutterSecureStorage();
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);

        await storage.write(key: 'token', value: token);
        await storage.write(key: 'id', value: user.id.toString());

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen(userName: user.name)));
      }else{
        SnackbarHelper.showMessage(context, 'Извините, произошла ошибка');
      }
    }catch (e){
      print(e);
      SnackbarHelper.showMessage(context, 'Произошла ошибка сети $e', isSuccess: false);
    }
  }

  Future<void> _signIn() async{
    if(_loginController.text.isEmpty || _passwordController.text.isEmpty){
      SnackbarHelper.showMessage(context, "Не все поля заполнены", isSuccess: false);
      return;
    }

    final url = Uri.parse('$baseUrl/auth/token');
    try{
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': _loginController.text,
          'password': _passwordController.text,
          'grant_type': 'password',
        }.map((key, value) => MapEntry(key, value.toString())),
      );

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        _extractToken(data['access_token']);
      }else{
        SnackbarHelper.showMessage(context, 'Неверный логин или пароль', isSuccess: false);
      }
    }catch (e){
      SnackbarHelper.showMessage(context, 'Произошла ошибка сети', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 87,),
            Center(
              child: Image.asset("assets/icons/LogoNight.png"),
            ),
            SizedBox(height: 14,),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Connect',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  TextSpan(
                    text: 'Card',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C4DFF),
                    )
                  )
                ]
              ),
            ),
            SizedBox(height: 50,),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Создавай и делись ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'визитками нового поколения',
                    style: TextStyle(
                      color: const Color(0xFF7C4DFF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )
                  )
                ]
              ),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _loginController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Почта или телефон',
                hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Пароль',
                hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 50),
            //Кнопка войти
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _signIn();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Войти', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            SizedBox(height: 15,),
            //Кнопка зарегистрироваться
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Зарегистрироваться', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'или войти через',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TelegramAuthScreen()));
                    },
                    icon: Image.asset('assets/icons/telegram-logo.png', height: 28, width: 28,),
                    label: const Text('Telegram', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      minimumSize: const Size.fromHeight(51),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const VkAuthScreen()));
                    },
                    // icon: Image.asset('assets/icons/vk-logo.png', height: 28, width: 28,),
                    icon: Icon(BoxIcons.bxl_vk),
                    label: const Text('ВКонтакте', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4C75A3),
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      minimumSize: const Size.fromHeight(51),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(dotenv.env['APP_VERSION'] ?? 'ConnectCard v.1.0.0'),
            )
          ],
        ),
      ),
    );
  }

}