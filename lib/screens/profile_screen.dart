import 'package:connect_card/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _vkController.text = 'Не авторизован';
    _telegramController.text = 'https://t.me/username';
    _mailController.text = 'example@gmail.com';
    _phoneController.text = '+7 800 555-35-35';
    _passwordController.text = 'Пароль для аккаунта не установлен';
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const BackButton(color: Colors.purpleAccent),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 55,
                  ),
                  SizedBox(height: 10,),

                  Text('Сане4ка', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF7C4DFF)),),

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
                            _social(BoxIcons.bxl_vk, _vkController),
                            _social(BoxIcons.bxl_telegram, _telegramController),
                            _social(Icons.mail, _mailController),
                            _social(EvaIcons.phone, _phoneController),
                            _social(Icons.password, _passwordController),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 25,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: (){
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        child: Text('Редактировать профиль', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: (){

                        },
                        child: Text('Настройки приложения', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Color(0xFF952424),
                          padding: EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: (){

                        },
                        child: Text('Выйти из аккаунта', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))
                      ),
                    ),
                  ),                                
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _social(IconData icon, TextEditingController _controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          SizedBox(width: 17),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Color(0xFF1B1A20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFF2A272F)),
              ),
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      style: _textStyle,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                      maxLines: 1,
                    )
                  : Text(
                      _controller.text.isNotEmpty
                          ? _controller.text
                          : 'Не авторизован',
                      style: _textStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
            ),
          )
        ],
      ),
    );
  }
}