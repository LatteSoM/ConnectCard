import 'dart:convert';
import 'dart:io';
import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/authScreens/telegram_auth_screen.dart';
import 'package:connect_card/screens/authScreens/vk_auth_screen.dart';
import 'package:connect_card/screens/login_screen.dart';
import 'package:connect_card/screens/settings_screen.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

enum OverlayMessageType { enteringEdit, savingChanges, cancelingEdit }

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin{
  final storage = FlutterSecureStorage();
  late AnimationController _overlayController;
  bool _showOverlay = false;
  OverlayMessageType _overlayMessageType = OverlayMessageType.enteringEdit;

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
  String? avatar = "";
  bool _isChangingPassword = false;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final phoneMask = MaskTextInputFormatter(mask: '+7 (###) ###-##-##');

  File? _selectedImage;

  @override
  void initState(){
    super.initState();
    _loadUser();
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _showOverlayAnimation() async {
    setState(() => _showOverlay = true);
    await _overlayController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> _hideOverlayAnimation() async {
    await Future.delayed(const Duration(seconds: 1));
    await _overlayController.reverse();
    if (mounted) setState(() => _showOverlay = false);
  }

  Future<void> _changeEditingState(bool isEditing) async {
    setState(() => _isEditing = isEditing);
    await _hideOverlayAnimation();
  }

  void _enterEditMode() async {
    setState(() => _overlayMessageType = OverlayMessageType.enteringEdit);
    await _showOverlayAnimation();
    await _changeEditingState(true);
  }

  void _cancelEditing() async {
    setState(() => _overlayMessageType = OverlayMessageType.cancelingEdit);
    await _showOverlayAnimation();
    await _changeEditingState(false);
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  Future<void> _changeInfo() async{
    setState(() => _overlayMessageType = OverlayMessageType.savingChanges);
    await _showOverlayAnimation();
    final token = await storage.read(key: 'token');

    final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/users/${user.id}'));
    request.headers['Authorization'] = 'Bearer $token';

    final userUpdate = user.copyWith(
      name: _nameController.text.trim() != name ? _nameController.text.trim() : null,
      email: _mailController.text.trim(),
      phone: _phoneController.text,
    );
    request.fields['user_update'] = jsonEncode(userUpdate.toJson(
      password: _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null,
    ));

    if(_selectedImage != null) {
      final fileStream = http.ByteStream(_selectedImage!.openRead());
      final length = await _selectedImage!.length();
      final multipartFile = http.MultipartFile(
        'avatar',
        fileStream,
        length,
        filename: _selectedImage!.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    print(request.fields);

    final response = await request.send();

    var responseData = await response.stream.bytesToString();

    if(response.statusCode == 200) {
      await _changeEditingState(false);
    }else {
      final error = jsonDecode(responseData);
      if(error['detail'] == 'Email already registered') {
        SnackbarHelper.showMessage(context, 'Данный email уже занят', isSuccess: false);
        _loadFields(user);
      }
    }

    // final url = Uri.parse('$baseUrl/users/${user.id}');
    // final updateUser = user.copyWith(
    //   email: _mailController.text.trim(),
    //   phone: _phoneController.text,
    // );
    // try{
    //   final response = await http.put(
    //     url,
    //     headers: {
    //       'Content-Type': 'application/json',
    //     },
    //     body: jsonEncode(updateUser.toJson(
    //       password: _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null,
    //     )),
    //   );
    //   if(response.statusCode == 200){
    //     await _changeEditingState(false);
    //   }else{
    //     final error = jsonDecode(response.body);
    //     if(error['detail'] == 'Email already registered'){
    //       SnackbarHelper.showMessage(context, 'Данный email уже занят', isSuccess: false);
    //       _loadFields(user);
    //     }
    //   }
    // }catch (e){
    //   SnackbarHelper.showMessage(context, 'Извините, произошла ошибка сети', isSuccess: false);
    // }
  }

  Future<void> _pickImage() async {
    // if(await Permission.photos.request().isGranted) {
    //   final picker = ImagePicker();
    //   final pickedFile = await picker.pickImage(
    //     source: ImageSource.gallery,
    //   );

    //   if(pickedFile != null) {
    //     setState(() {
    //       _selectedImage = File(pickedFile.path);
    //     });
    //   }
    // }else {
    //   SnackbarHelper.showMessage(context, 'Необходимо разрешение для доступа к галерее', isSuccess: false);
    // }
    final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if(pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
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
      _nameController.text = name;
      avatar = user.avatar;
    });
  }

  Future<void> _loadUser() async{
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

  Future<void> _logOut() async {
    final storage = FlutterSecureStorage();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = await storage.read(key: "token");
    try{
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
            'Authorization': 'Bearer $token',
          }
      );
      if(response.statusCode == 200){
        await storage.deleteAll();
        await prefs.remove('tutorial_shown');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }else{
        SnackbarHelper.showMessage(context, 'Извините, произошла ошибка', isSuccess: false);
      }
    }catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if(_isEditing)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(onPressed: (){
                            _changeInfo();
                            // setState(() {
                            //   _isEditing = false;
                            // });
                          },
                          icon: Icon(Icons.check)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // CircleAvatar(
                      //   radius: 55,
                      // ),
                      _buildAvatar(),
                      SizedBox(height: 10,),

                      // Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF7C4DFF)),),
                      _buildEditableName(),

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
                                _social(Icons.password, _passwordController, isPassword: true, hasPassword: true),
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
                            onPressed: () {
                              _enterEditMode();
                            },
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
                              _logOut();
                            },
                            withBottomMargin: false,
                          ),
                        ],
                      ),
                      if(_isEditing)
                      _buildActionButton(
                            text: 'Выйти из редактирования',
                            backgroundColor: const Color(0xFF952424),
                            onPressed: _cancelEditing,
                            withBottomMargin: false,
                          ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (_showOverlay)
          AnimatedBuilder(
            animation: _overlayController,
            builder: (context, child) {
              String title;
              String subtitle;
              IconData icon;
              
              switch (_overlayMessageType) {
                case OverlayMessageType.enteringEdit:
                  title = 'Режим редактирования';
                  subtitle = 'Измените нужные поля';
                  icon = Icons.edit;
                  break;
                case OverlayMessageType.savingChanges:
                  title = 'Изменения сохранены';
                  subtitle = 'Ваши данные успешно обновлены';
                  icon = Icons.check_circle;
                  break;
                case OverlayMessageType.cancelingEdit:
                  title = 'Редактирование отменено';
                  subtitle = 'Изменения не были сохранены';
                  icon = Icons.cancel;
                  break;
              }

              return Opacity(
                opacity: _overlayController.value,
                child: Container(
                  color: Colors.black.withOpacity(1),
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 50, color: Colors.white),
                        const SizedBox(height: 20),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditableName() {
    return _isEditing
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 50,
                    maxWidth: 200,
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Color(0xFF7C4DFF),
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 4),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.edit,
                  color: Color(0xFF7C4DFF),
                  size: 20,
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Color(0xFF7C4DFF),
              ),
            ),
          );
  }

    Widget _buildAvatar() {
      return Stack(
      alignment: Alignment.center,
      children: [
        _selectedImage != null
          ? CircleAvatar(
            radius: 55,
            backgroundImage: FileImage(_selectedImage!),
          )
          : avatar != null
            ? CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage('$baseUrl$avatar'),
              onBackgroundImageError: (exception, stackTrace) {

              },
            )
            : CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 55,
                color: Colors.white,
              ),
            ),
        if (_isEditing)
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),

        if (_isEditing)
          GestureDetector(
            onTap: () {
              _pickImage();
              // print("Vibor");
            },
            child: Icon(
              Icons.photo_camera,
              color: Colors.white,
              size: 30,
            ),
          ),
      ],
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
                                                  inputFormatters: [
                                                    if (icon == EvaIcons.phone) phoneMask
                                                  ],
                                                  onChanged: (value) {
                                                    if(icon == EvaIcons.phone && !_phoneController.text.startsWith('+7')) {
                                                      _phoneController.text = '+7';
                                                    }
                                                  },
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