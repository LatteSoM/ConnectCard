import 'dart:convert';
import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/authScreens/telegram_auth_screen.dart';
import 'package:connect_card/screens/authScreens/vk_auth_screen.dart';
import 'package:connect_card/screens/settings_screen.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{
  User user = User.empty();
  final baseUrl = dotenv.env['BASE_URL'];
  String? formattedPhone;
  bool _isEditing = false;
  final _textStyle = TextStyle(
    color: Colors.grey[400],
    height: 1.0,
    fontSize: 12,
  );
  final TextEditingController _vkController = TextEditingController();
  final TextEditingController _telegramController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  String? _initialMail = '';
  String? _initialPhone = '';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String name = "";
  bool _isChangingPassword = false;
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _loadUser();
    // formattedPhone = formatRussianPhone();
  }

  // String formatRussianPhone() {
  //   String phone = widget.user.phoneNumber!;
  //   final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

  //   if (!cleaned.startsWith('+7') || cleaned.length != 12) {
  //     return phone;
  //   }

  //   final countryCode = '+7';
  //   final areaCode = cleaned.substring(2, 5); 
  //   final part1 = cleaned.substring(5, 8);
  //   final part2 = cleaned.substring(8, 10);
  //   final part3 = cleaned.substring(10, 12);

  //   return '$countryCode ($areaCode) $part1-$part2-$part3';
  // }

  Future<void> _changeInfo() async{
    final url = Uri.parse('$baseUrl/users/${user.id}');
    final updateUser = user.copyWith(
      email: _mailController.text.trim(),
      phone: _phoneController.text,
    );
    try{
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateUser.toJson(
          password: _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null,
        )),
      );
      if(response.statusCode == 200){
        SnackbarHelper.showMessage(context, 'Данные успешно изменены');
      }else{
        final error = jsonDecode(response.body);
        if(error['detail'] == 'Email already registered'){
          SnackbarHelper.showMessage(context, 'Данный email уже занят', isSuccess: false);
          _loadFields(user);
        }
      }
    }catch (e){
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка сети', isSuccess: false);
    }
  }

  void _loadFields(User user){
    setState(() {
      _vkController.text = user.isVkAuth ? "Авторизован" : "";
      _telegramController.text = user.isTelegramAuth ? "Авторизован" : "";
      _mailController.text = _initialMail ?? "Не указана";
      _phoneController.text = _initialPhone ?? "Не указан";
      _passwordController.text = user.hasPassword ? "**************" : "Пароль для аккаунта не установлен";
      name = user.name;
    });
  }

  Future<void> _loadUser() async{
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");
    if(token != null){
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
          user = User.fromJson(data);

          _initialMail = user.email;
          _initialPhone = user.phone;

          _loadFields(user);

        }else{
          SnackbarHelper.showMessage(context, 'Произошла ошибка', isSuccess: false);
        }
      }catch (e){
        SnackbarHelper.showMessage(context, 'Извините, произошла ошибка сети', isSuccess: false);
      }
    }else{
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const BackButton(color: Colors.purpleAccent),
                    ),
                    if(_isEditing)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(onPressed: (){
                        _changeInfo();
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      icon: Icon(Icons.check)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 55,
                  ),
                  SizedBox(height: 10,),

                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF7C4DFF)),),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      color: Color(0xFF1C1A1F),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Аккаунт', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 12),
                            _social(BoxIcons.bxl_vk, _vkController, isFirstTwo: true, onHyperTextPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => VkAuthScreen()));
                            },),
                            _social(BoxIcons.bxl_telegram, _telegramController, isFirstTwo: true, onHyperTextPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TelegramAuthScreen()));
                            }),
                            _social(Icons.mail, _mailController),
                            _social(EvaIcons.phone, _phoneController),
                            _social(Icons.password, _passwordController, isPassword: true),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 25,),
                  if(!_isEditing)
                  Column(
                    children: [
                      _buildActionButton(
                        text: 'Редактировать профиль',
                        onPressed: () => setState(() => _isEditing = !_isEditing),
                      ),
                      _buildActionButton(
                        text: 'Настройки приложения',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                        },
                      ),
                      _buildActionButton(
                        text: 'Выйти из аккаунта',
                        backgroundColor: const Color(0xFF952424),
                        onPressed: () {
                          SnackbarHelper.showMessage(context, 'Logout ёпта');
                        },
                        withBottomMargin: false,
                      ),
                    ],
                  ),
                  if(_isEditing)
                  _buildActionButton(
                        text: 'Выйти из редактирования',
                        backgroundColor: const Color(0xFF952424),
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                        withBottomMargin: false,
                      ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    Color backgroundColor = const Color(0xFF1C1A1F),
    required VoidCallback onPressed,
    bool withBottomMargin = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: onPressed,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (withBottomMargin) const SizedBox(height: 15),
        ],
      ),
    );
  }


  Widget _social(IconData icon, TextEditingController _controller, {
    bool isFirstTwo = false, 
    bool isPassword = false,
    bool hasPassword = false,
    VoidCallback? onHyperTextPressed,
    VoidCallback? onPasswordPressed,
  }) {
    final bool isAuthorized = _controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 17),
              Expanded(
                child: isPassword && _isEditing && !_isChangingPassword
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C1A1F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: const Color(0xFF2A272F)),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _isChangingPassword = true;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          alignment: Alignment.center,
                          child: Text(
                            hasPassword ? 'Изменить пароль' : 'Задать пароль',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1A20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2A272F)),
                        ),
                        child: _isEditing && _isChangingPassword && isPassword
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B1A20),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF2A272F)),
                                      ),
                                      child: TextField(
                                        controller: _newPasswordController,
                                        style: _textStyle,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                          hintText: 'Новый пароль',
                                          hintStyle: TextStyle(color: Colors.grey),
                                        ),
                                        obscureText: true,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B1A20),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF2A272F)),
                                      ),
                                      child: TextField(
                                        controller: _confirmPasswordController,
                                        style: _textStyle,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                          hintText: 'Подтвердите пароль',
                                          hintStyle: TextStyle(color: Colors.grey),
                                        ),
                                        obscureText: true,
                                      ),
                                    ),
                                    if (_isChangingPassword && _isEditing && isPassword)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF1c1a1f),
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                if (_newPasswordController.text.isNotEmpty && 
                                                    _newPasswordController.text == _confirmPasswordController.text) {
                                                  setState(() {
                                                    _isChangingPassword = false;
                                                  });
                                                }
                                              },
                                              child: const Text('Сохранить', style: TextStyle(color: Colors.white, fontSize: 12),),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                _isChangingPassword = false;
                                                _newPasswordController.clear();
                                                _confirmPasswordController.clear();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _isEditing
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                          child: isAuthorized
                                              ? TextField(
                                                  controller: _controller,
                                                  style: _textStyle,
                                                  decoration: const InputDecoration(
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.zero,
                                                    border: InputBorder.none,
                                                  ),
                                                )
                                              : Text(
                                                  'Не авторизован',
                                                  style: _textStyle.copyWith(color: Colors.grey[400]),
                                                ),
                                        ),
                                      ),
                                      if (isFirstTwo && _isEditing)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: isAuthorized
                                              ? IconButton(
                                                  icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                                  onPressed: () {
                                                    _controller.clear();
                                                    setState(() {});
                                                  },
                                                )
                                              : TextButton(
                                                  onPressed: onHyperTextPressed,
                                                  child: const Text(
                                                    'Авторизовать',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                    ],
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    child: isPassword && isAuthorized
                                        ? Text(
                                            '••••••••••••••••',
                                            style: _textStyle,
                                          )
                                        : Text(
                                            isAuthorized ? _controller.text : 'Не авторизован',
                                            style: _textStyle,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                  ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}