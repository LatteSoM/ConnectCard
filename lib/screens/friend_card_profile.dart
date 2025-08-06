import 'dart:convert';

import 'package:connect_card/screens/visit_card_profile.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;

class FriendCardProfile extends StatefulWidget{
  @override
  State<FriendCardProfile> createState() => _FriendCardProfileState();
}

class _FriendCardProfileState extends State<FriendCardProfile>{
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'];
  String? _token;
  String? _id;
  Map<String, String> get headers {
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }

  @override
  void initState(){
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadCredentials();
    //Загрузка данных пользователя
  }

  Future<void> _loadCredentials() async {
    _id = await storage.read(key: 'id');
    _token = await storage.read(key: 'token');
  }

  Future<void> _addToContact(String card_id, String event_id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contacts/'),
      headers: headers,
      body: jsonEncode({
        'card_id': card_id,
        'user_id': _id,
      }),
    );
    if(response.statusCode == 200){
      SnackbarHelper.showMessage(context, 'Контакт успешно добавлен');
    }else{
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка', isSuccess: false);
    }
  }

  void showMeetupDialog(BuildContext context) {
    final user_id = '2f328310-d534-4aa5-abcd-6e5af7493ade';
    final card_id = 'e0d6c449-927e-4a43-aa8c-cc98d674b957';
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 100),
          backgroundColor: Color(0xFF1E1E1E),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined, size: 40, color: Colors.blueAccent),
                SizedBox(height: 16),
                Text(
                  'Где вы познакомились?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                SizedBox(height: 12),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[400]),
                    children: [
                      const TextSpan(text: 'Укажите мероприятие, встречу, место или короткое описание. Это поле '),
                      TextSpan(
                        text: 'необязательное',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Например: Flutter Meetup...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _addToContact(card_id, '');
                        // print('Пользователь пропустил');
                      },
                      child: Text(
                        'Пропустить',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        String place = _controller.text.trim();
                        Navigator.of(context).pop();
                        print('Место встречи: $place');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Добавить',
                        style: TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const BackButton(color: Colors.purpleAccent),
                      ),
                    ),
                  ]
                  ),
                  //Аватарка
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage('https://example.com/your-avatar.jpg'), // Заменить на свою
                      ),
                    ],
                  ),
                  // _editableAvatar(),
                  const SizedBox(height: 16,),
                  //Имя
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Барак Обама',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  // _editableText(
                  //   18,
                  //   controller: _nameController,
                  //   onEditPressed: () {                    
                  //   },),

                  const SizedBox(height: 7,),

                  //Должность
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Старший кассир',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w200,
                        ),
                      )
                    ],
                  ),
                  // _editableText(
                  //   14,
                  //   controller: _positionController,
                  //   isBold: false,
                  //   onEditPressed: () {    
                  //   },),

                  const SizedBox(height: 8,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesome.building, color: Colors.white, size: 24,),
                      SizedBox(width: 5,),
                      //Организация
                      Row(
                    children: [
                      Text(
                        'ООО KFC',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w200,
                        ),
                      )
                    ],
                  ),
                      // _editableText(
                      //   14,
                      //   isBold: false,
                      //   controller: _companyController,),
                    ],
                  ),

                  const SizedBox(height: 28,),

                  //О Себе
                  Row(
                    children: [
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w200,
                        ),
                      )
                    ],
                  ),
                  // _editableText(
                  //   14,
                  //   controller: _aboutController,
                  //   isBold: false),

                  const SizedBox(height: 25,),
                  Text("Связаться со мной", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),

                  SizedBox(height: 16),

                  Column(
                    children: [
                      _buildInfoCard(
                        icon: Icon(Icons.email_outlined, color: Colors.white, size: 32,),
                        title: "Email",
                        subtitle: 'mail.ru',
                        ),
                      // if (contactInfo.email != null)
                      //   _buildInfoCardWithDelete(
                      //     icon: Icon(Icons.email_outlined, color: Colors.white, size: 32),
                      //     title: "Email",
                      //     subtitle: contactInfo.email!,
                      //     onDelete: () => _removeMainInfo('email'),
                      //   ),
                      _buildInfoCard(
                        icon: Icon(Icons.phone, color: Colors.white, size: 32,),
                        title: "Телефон",
                        subtitle: '+7 900 999 99 99',
                        ),
                      // if (contactInfo.phone != null)
                      //   _buildInfoCardWithDelete(
                      //     icon: Icon(Icons.phone, color: Colors.white, size: 32),
                      //     title: "Телефон",
                      //     subtitle: contactInfo.phone!,
                      //     onDelete: () => _removeMainInfo('phone'),
                      //   ),
                      _buildInfoCard(
                        icon: Icon(Icons.language, color: Colors.white, size: 32,),
                        title: "Сайт",
                        subtitle: 'https://fmrkmfwrf.com',
                        ),
                      // if (contactInfo.website != null)
                      //   _buildInfoCardWithDelete(
                      //     icon: Icon(Icons.language, color: Colors.white, size: 32),
                      //     title: "Сайт",
                      //     subtitle: contactInfo.website!,
                      //     onDelete: () => _removeMainInfo('website'),
                      //   ),
                      
                      // if (_isEditing && _availableMainInfoTypes.isNotEmpty)
                      //   Padding(
                      //     padding: EdgeInsets.only(top: 16),
                      //     child: _buildAddButton(
                      //       'Добавить основную информацию', 
                      //       () => setState(() => _showAddMainInfo = true),
                      //     ),
                      //   ),
                      
                      // if (_showAddMainInfo && _isEditing)
                      //   _buildAddInfoForm(
                      //     types: _availableMainInfoTypes,
                      //     onTypeSelected: (type) => _selectedInfoType = type,
                      //     onAddPressed: _addMainInfo,
                      //     onCancel: () => setState(() => _showAddMainInfo = false),
                      //     controller: _mainInfoController,
                      //   ),
                    ],
                  ),

                  SizedBox(height: 15),

                  Text("Социальные сети", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),

                  SizedBox(height: 16),

                  Wrap(
                    spacing: 13,
                    runSpacing: 8,
                    children: [
                      _buildSocialCard(
                        icon: Icon(BoxIcons.bxl_telegram, color: Colors.white, size: 24,),
                        title: "Телеграм",
                        subtitle: '@sanechka',
                        ),
                      // if (socialMedia.telegram != null)
                      // _buildSocialCardWithDelete(
                      //   icon: Icon(BoxIcons.bxl_telegram, color: Colors.white, size: 24),
                      //   title: "Телеграм",
                      //   subtitle: socialMedia.telegram!,
                      //   onDelete: () => _removeSocialMedia('telegram'),
                      // ),
                      _buildSocialCard(
                        icon: Icon(EvaIcons.linkedin, color: Colors.white, size: 24,),
                        title: "LinkedIn",
                        subtitle: 'linkedin322',
                        ),
                      // if (socialMedia.linkedin != null)
                      // _buildSocialCardWithDelete(
                      //   icon: Icon(EvaIcons.linkedin, color: Colors.white, size: 24),
                      //   title: "LinkedIn",
                      //   subtitle: socialMedia.linkedin!,
                      //   onDelete: () => _removeSocialMedia('linkedin'),
                      // ),
                      _buildSocialCard(
                        icon: Icon(Bootstrap.github, color: Colors.white, size: 24,),
                        title: "GitHyb",
                        subtitle: 'https://github.com/Alex',
                        ),
                      // if (socialMedia.github != null)
                      // _buildSocialCardWithDelete(
                      //   icon: Icon(Bootstrap.github, color: Colors.white, size: 24),
                      //   title: "GitHub",
                      //   subtitle: socialMedia.github!,
                      //   onDelete: () => _removeSocialMedia('github'),
                      // ),
                      _buildSocialCard(
                        icon: Icon(Bootstrap.twitter_x, color: Colors.white, size: 24,),
                        title: "X",
                        subtitle: 'XXXXXXX',
                        ),
                      // if (socialMedia.twitter != null)
                      // _buildSocialCardWithDelete(
                      //   icon: Icon(Bootstrap.twitter_x, color: Colors.white, size: 24),
                      //   title: "X",
                      //   subtitle: socialMedia.twitter!,
                      //   onDelete: () => _removeSocialMedia('twitter'),
                      // ),
                    ],
                  ),

                  // if (_isEditing && _availableSocialMediaTypes.isNotEmpty)
                  // Padding(
                  //   padding: EdgeInsets.only(top: 16),
                  //   child: _buildAddButton(
                  //     'Добавить социальную сеть', 
                  //     () {      
                  //       setState(() => _showAddSocialMedia = true);
                  //       WidgetsBinding.instance.addPostFrameCallback((_) {
                  //         final context = _socialFormKey.currentContext;
                  //         if (context != null) {
                  //           Scrollable.ensureVisible(
                  //             context,
                  //             duration: Duration(milliseconds: 300),
                  //             curve: Curves.easeOut,
                  //           );
                  //         }
                  //       }); 
                  //     }
                  //   ),
                  // ),

                  // if (_showAddSocialMedia && _isEditing)
                  // Padding(
                  //   key: _socialFormKey,
                  //   padding: EdgeInsets.only(top: 16),
                  //   child: _buildAddInfoForm(
                  //     isSocial: true,
                  //     types: _availableSocialMediaTypes,
                  //     onTypeSelected: (type) => _selectedSocialMediaType = type,
                  //     onAddPressed: _addSocialMedia,
                  //     onCancel: () => setState(() => _showAddSocialMedia = false),
                  //     controller: _socialMediaController,
                  //   ),
                  // ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: Icon(OctIcons.share, color: Colors.white),
                        label: Text('Поделиться ссылкой на визитку', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    ),
                  ),
                  SizedBox(height: 8,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showMeetupDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: Icon(OctIcons.person_add, color: Colors.white),
                        label: Text('Добавить в контакты', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    ),
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required Widget icon,
    required String title,
    required String subtitle,
  }) {
    return Stack(
      children: [
        InfoCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSocialCard({
    required Widget icon,
    required String title,
    required String subtitle,
  }) {
    return Stack(
      children: [
        InfoCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
        ),
      ],
    );
  }

}