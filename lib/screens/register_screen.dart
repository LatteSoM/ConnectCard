import 'dart:convert';

import 'package:connect_card/main.dart';
import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/authScreens/telegram_auth_screen.dart';
import 'package:connect_card/screens/authScreens/vk_auth_screen.dart';
import 'package:connect_card/screens/welcome_screen.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final baseUrl = dotenv.env['BASE_URL'];
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool consentGiven = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (!consentGiven) {
      SnackbarHelper.showMessage(context, 'Необходимо согласие на обработку данных', isSuccess: false);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      SnackbarHelper.showMessage(context, 'Пароли не совпадают', isSuccess: false);
      return;
    }

    final url = Uri.parse('$baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "login": _loginController.text.trim(),
          "password": _passwordController.text,
          // "consent_given": consentGiven,
        }),
      );

      if (response.statusCode == 200) {
        SnackbarHelper.showMessage(context, 'Вы успешно зарегистрировались');
        final jsonData = jsonDecode(response.body);
        await _extractToken(jsonData['access_token'], jsonData['refresh_token']);
      } else {
        final erroData = jsonDecode(response.body);
        final error = erroData['detail'];
        SnackbarHelper.showMessage(
          context,
          error == 'Username already registered' ? 'Данный логин уже занят' : 'Ошибка регистрации',
          isSuccess: false,
        );
      }
    } catch (e) {
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка сети', isSuccess: false);
    }
  }

  Future<void> _extractToken(String token, String refreshToken) async{
    print('Pereshel');
    final url = Uri.parse('$baseUrl/auth/current_user');
    try{
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        }
      );
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);

        await storage.write(key: 'token', value: token);
        await storage.write(key: 'refresh_token', value: refreshToken);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.purpleAccent.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const BackButton(color: Colors.purpleAccent),
                          ),
                        ),
                        Center(
                          child: Image.asset("assets/icons/LogoNight.png"),
                        ),
                        const SizedBox(height: 14),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Connect',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'Card',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7C4DFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
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
                                  color: Color(0xFF7C4DFF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Имя',
                            hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                            filled: true,
                            fillColor: const Color(0xFF1A1A1A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Обязательное поле' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                            filled: true,
                            fillColor: const Color(0xFF1A1A1A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.contains('@') ? null : 'Некорректный email',
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _loginController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Логин',
                            hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                            filled: true,
                            fillColor: const Color(0xFF1A1A1A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Обязательное поле' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
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
                          validator: (value) => value!.length < 6 ? 'Минимум 6 символов' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Подтверждение пароля',
                            hintStyle: const TextStyle(color: Color(0xFF9C9C9C)),
                            filled: true,
                            fillColor: const Color(0xFF1A1A1A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value != _passwordController.text ? 'Пароли не совпадают' : null,
                        ),
                        const SizedBox(height: 15),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Я согласен на обработку персональных данных',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: consentGiven,
                          onChanged: (value) => setState(() => consentGiven = value!),
                          activeColor: Colors.deepPurpleAccent,
                          checkColor: Colors.white,
                          tileColor: const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Создать аккаунт',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'или зарегистрироваться через',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TelegramAuthScreen(),
                                    ),
                                  );
                                },
                                icon: Image.asset(
                                  'assets/icons/telegram-logo.png',
                                  height: 28,
                                  width: 28,
                                ),
                                label: const Text(
                                  'Telegram',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const VkAuthScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(BoxIcons.bxl_vk),
                                label: const Text(
                                  'ВКонтакте',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4C75A3),
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
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(dotenv.env['APP_VERSION'] ?? 'ConnectCard v.1.0.0'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}