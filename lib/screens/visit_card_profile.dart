import 'dart:convert';
import 'dart:io';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/list_of_visit_card.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum VisitCardTemplate {
  template1,
  template2,
  template3,
  template4,
}


class VisitCardProfile extends StatefulWidget{
  @override
  State<VisitCardProfile> createState() => _VisitCardProfileState();
}

class _VisitCardProfileState extends State<VisitCardProfile> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'];
  final GlobalKey _socialFormKey = GlobalKey();//Для анимации прокрутки
  bool _isEditing = false;
  bool _showQrCode = false;
  bool _showAddMainInfo = false;
  bool _showAddSocialMedia = false;
  String? _selectedInfoType;
  String? _selectedSocialMediaType;
  final TextEditingController _socialMediaController = TextEditingController();
  final TextEditingController _mainInfoController = TextEditingController();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  
  ContactInfo contactInfo = ContactInfo();
  SocialMedia socialMedia = SocialMedia();

  final phoneMask = MaskTextInputFormatter(mask: '+7 (###) ###-##-##');

  File? _selectedImage;
  String? avatar;

  VisitCardTemplate? _selectedCardTemplate;
  List<LinkWidget> linkWidgets = [];

  

  @override
  void initState() {
    super.initState();
    _mainInfoController.addListener(_updateMainInfoPrefix);
    _socialMediaController.addListener(_updateSocialLinkPrefix);
    _loadInfo();
    // _nameController.text = "Барак обама";
    _positionController.text = "Старший кассир";
    _companyController.text = """ООО "KFC" """;
    _aboutController.text = "Просто чиловый парень";
  }

  @override
  void dispose(){
    _mainInfoController.removeListener(_updateMainInfoPrefix);
    _socialMediaController.removeListener(_updateSocialLinkPrefix);
    _mainInfoController.dispose();
    _socialMediaController.dispose();
    super.dispose();
  }

  Future<void> _loadInfo() async {
    final id = await storage.read(key: 'id');
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/users/$id');
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
        setState(() {
          _nameController.text = user.name;
          contactInfo.email = user.email;
          contactInfo.phone = user.phone;
          avatar = user.avatar;
        });
      }else{
        SnackbarHelper.showMessage(context, 'Извините, произошла ошибка', isSuccess: false);  
      }
    }catch (e){
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка', isSuccess: false);
    }
  }

  Future<void> _saveData() async {
    final client = http.Client();
    final token = await storage.read(key: 'token');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final contacts = await client.post(
        Uri.parse('$baseUrl/contact-info/bulk'),
        headers: headers,
        body: jsonEncode({'contacts': contactInfo.toContactList()}),
      );

      final widgets = await client.post(
        Uri.parse('$baseUrl/link-widgets/bulk'),
        headers: headers,
        body: jsonEncode({'widgets': socialMedia.toWidgetsList()}),
      );


      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/cards/'));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      final data = {
        'fullname': _nameController.text.trim(),
        'company': _companyController.text.trim(),
        'position': _positionController.text.trim(),
        'about': _aboutController.text.trim(),
        'contact_info_ids': (jsonDecode(contacts.body) as List).map((c) => c['id']).toList(),
        'link_widget_ids': (jsonDecode(widgets.body) as List).map((w) => w['id']).toList(),
      };

      request.fields['data'] = jsonEncode(data);

      if(_selectedImage != null) {
        final fileStram = http.ByteStream(_selectedImage!.openRead());
        final length = await _selectedImage!.length();
        final multipartFile = http.MultipartFile(
          'avatar',
          fileStram,
          length,
          filename: _selectedImage!.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();

      // final card = await client.post(
      //   Uri.parse('$baseUrl/cards/'),
      //   headers: headers,
      //   body: jsonEncode({
      //     'fullname': _nameController.text.trim(),
      //     'company': _companyController.text.trim(),
      //     'position': _positionController.text.trim(),
      //     'about': _aboutController.text.trim(),
      //     'contact_info_ids': (jsonDecode(contacts.body) as List).map((c) => c['id']).toList(),
      //     'link_widget_ids': (jsonDecode(widgets.body) as List).map((w) => w['id']).toList(),
      //   }),
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Text(
              'Визитка создана',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            action: SnackBarAction(
              label: 'К списку',
              textColor: Colors.blueAccent,
              onPressed: () => Navigator.pop(context),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }


    } catch (e) {
      print(e);
    } finally {
      client.close();
    }
    // Navigator.pop(context);
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

  void _removeMainInfo(String type) {
    setState(() {
      switch (type) {
        case 'email': contactInfo.email = null; break;
        case 'phone': contactInfo.phone = null; break;
        case 'website': contactInfo.website = null; break;
      }
    });
  }

  void _removeSocialMedia(String type) {
    setState(() {
      switch (type) {
        case 'telegram':
          socialMedia.telegram = null;
          linkWidgets.removeWhere((item) => item.name == 'Telegram');
          break;
        case 'linkedin':
          socialMedia.linkedin = null;
          linkWidgets.removeWhere((item) => item.name == 'Linkedin');
          break;
        case 'github':
          socialMedia.github = null;
          linkWidgets.removeWhere((item) => item.name == 'Github');
          break;
        case 'twitter':
          socialMedia.twitter = null;
          linkWidgets.removeWhere((item) => item.name == 'Twitter');
          break;
      }
    });
  }

  void _addMainInfo() {
    if (_mainInfoController.text.isNotEmpty && _selectedInfoType != null) {
      setState(() {
        switch (_selectedInfoType) {
          case 'email': contactInfo.email = _mainInfoController.text; break;
          case 'phone': contactInfo.phone = _mainInfoController.text; break;
          case 'website': contactInfo.website = _mainInfoController.text; break;
        }
        _mainInfoController.clear();
        _showAddMainInfo = false;
        _selectedInfoType = null;
      });
    }
  }

  void _addSocialMedia() {
    if (_socialMediaController.text.isNotEmpty && _selectedSocialMediaType != null) {
      setState(() {
        switch (_selectedSocialMediaType) {
          case 'telegram': socialMedia.telegram = _socialMediaController.text; break;
          case 'linkedin': socialMedia.linkedin = _socialMediaController.text; break;
          case 'github': socialMedia.github = _socialMediaController.text; break;
          case 'twitter': socialMedia.twitter = _socialMediaController.text; break;
        }
        _convertSocialToLinkWidget();
        _socialMediaController.clear();
        _showAddSocialMedia = false;
        _selectedSocialMediaType = null;
      });
    }
  }

  void _convertSocialToLinkWidget() {
    final socialNames = {
      'telegram': 'Telegram',
      'linkedin': 'Linkedin',
      'github': 'GitHub',
      'twitter': 'Twitter',
    };

    final name = socialNames[_selectedSocialMediaType];
    if (name != null) {
      setState(() {
        linkWidgets.add(LinkWidget(
          id: '',
          link: _socialMediaController.text,
          name: name,
          icon: _selectedSocialMediaType,
        ));
      });
    }
  }

  String? _validateMainInput(String? value){
    print(_selectedInfoType);
    if(value == null || value.isEmpty) {
      return 'Введите информацию';
    }

    if(_selectedInfoType == 'email') {
      if (!RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
        ).hasMatch(value)) {
          return 'Введите корректный email';
      }
    }

    if(_selectedInfoType == 'phone') {
      if(!RegExp(
        r'^(\+?7|8)[\s\-]?\(?[0-9]{3}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}$',
        ).hasMatch(value)) {
          return 'Введите корректный номер телефона';
      }
    }

    if(_selectedInfoType == 'website') {
      if(!Uri.parse(value).isAbsolute){
        return 'Введите корректный URL';
      }
    }
    return null;
  }

  void _updateMainInfoPrefix() {
    if (_selectedInfoType == 'phone' && !_mainInfoController.text.startsWith('+7')) {
      _mainInfoController.text = '+7';
    } else if (_selectedInfoType == 'website' && !_mainInfoController.text.startsWith('https://')) {
      _mainInfoController.text = 'https://';
    }
  }

  void _updateSocialLinkPrefix() {
    if(_selectedSocialMediaType == 'telegram' && !_socialMediaController.text.startsWith('@')) {
      _socialMediaController.text = '@';
    }
    if(_selectedSocialMediaType == 'github' && !_socialMediaController.text.startsWith('https://github.com/')) {
      _socialMediaController.text = 'https://github.com/';
    }
  }

  List<String> get _availableMainInfoTypes {
    List<String> types = [];
    if (contactInfo.email == null) types.add('email');
    if (contactInfo.phone == null) types.add('phone');
    if (contactInfo.website == null) types.add('website');
    return types;
  }

  List<String> get _availableSocialMediaTypes {
    List<String> types = [];
    if (socialMedia.telegram == null) types.add('telegram');
    if (socialMedia.linkedin == null) types.add('linkedin');
    if (socialMedia.github == null) types.add('github');
    if (socialMedia.twitter == null) types.add('twitter');
    return types;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EditingScope(
              isEditing: _isEditing,
              child: Column(
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Кнопка назад с таким же стилем, как в первом примере
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: (){
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                          }, 
                          icon: _isEditing ? Icon(Icons.close, color: Colors.red) : Icon(Icons.edit),
                        ),
                        if(!_isEditing)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton(
                              onPressed: () {
                                _saveData();
                              },
                              icon: Icon(Bootstrap.check_lg, color: Colors.green,),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                  //Аватарка
                  _editableAvatar(),
                  const SizedBox(height: 16,),
                  //Имя
                  _editableText(
                    18,
                    controller: _nameController,
                    onEditPressed: () {                    
                    },),

                  const SizedBox(height: 7,),

                  //Должность
                  _editableText(
                    14,
                    controller: _positionController,
                    isBold: false,
                    onEditPressed: () {    
                    },),

                  const SizedBox(height: 8,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesome.building, color: Colors.white, size: 24,),
                      SizedBox(width: 5,),
                      //Организация
                      _editableText(
                        14,
                        isBold: false,
                        controller: _companyController,),
                    ],
                  ),

                  const SizedBox(height: 28,),

                  //О Себе
                  _editableText(
                    14,
                    controller: _aboutController,
                    isBold: false),

                  const SizedBox(height: 25,),
                  Text("Связаться со мной", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),

                  SizedBox(height: 16),

                  Column(
                    children: [
                      if (contactInfo.email != null)
                        _buildInfoCardWithDelete(
                          icon: Icon(Icons.email_outlined, color: Colors.white, size: 32),
                          title: "Email",
                          subtitle: contactInfo.email!,
                          onDelete: () => _removeMainInfo('email'),
                        ),
                      if (contactInfo.phone != null)
                        _buildInfoCardWithDelete(
                          icon: Icon(Icons.phone, color: Colors.white, size: 32),
                          title: "Телефон",
                          subtitle: contactInfo.phone!,
                          onDelete: () => _removeMainInfo('phone'),
                        ),
                      if (contactInfo.website != null)
                        _buildInfoCardWithDelete(
                          icon: Icon(Icons.language, color: Colors.white, size: 32),
                          title: "Сайт",
                          subtitle: contactInfo.website!,
                          onDelete: () => _removeMainInfo('website'),
                        ),
                      
                      if (_isEditing && _availableMainInfoTypes.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: _buildAddButton(
                            'Добавить основную информацию', 
                            () => setState(() => _showAddMainInfo = true),
                          ),
                        ),
                      
                      if (_showAddMainInfo && _isEditing)
                        _buildAddInfoForm(
                          types: _availableMainInfoTypes,
                          onTypeSelected: (type) => _selectedInfoType = type,
                          onAddPressed: _addMainInfo,
                          onCancel: () => setState(() => _showAddMainInfo = false),
                          controller: _mainInfoController,
                        ),
                    ],
                  ),

                  SizedBox(height: 15),

                  Text("Социальные сети", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),

                  SizedBox(height: 16),

                  Wrap(
                    spacing: 13,
                    runSpacing: 8,
                    children: [
                      if (socialMedia.telegram != null)
                      _buildSocialCardWithDelete(
                        icon: Icon(BoxIcons.bxl_telegram, color: Colors.white, size: 24),
                        title: "Телеграм",
                        subtitle: socialMedia.telegram!,
                        onDelete: () => _removeSocialMedia('telegram'),
                      ),
                      if (socialMedia.linkedin != null)
                      _buildSocialCardWithDelete(
                        icon: Icon(EvaIcons.linkedin, color: Colors.white, size: 24),
                        title: "LinkedIn",
                        subtitle: socialMedia.linkedin!,
                        onDelete: () => _removeSocialMedia('linkedin'),
                      ),
                      if (socialMedia.github != null)
                      _buildSocialCardWithDelete(
                        icon: Icon(Bootstrap.github, color: Colors.white, size: 24),
                        title: "GitHub",
                        subtitle: socialMedia.github!,
                        onDelete: () => _removeSocialMedia('github'),
                      ),
                      if (socialMedia.twitter != null)
                      _buildSocialCardWithDelete(
                        icon: Icon(Bootstrap.twitter_x, color: Colors.white, size: 24),
                        title: "X",
                        subtitle: socialMedia.twitter!,
                        onDelete: () => _removeSocialMedia('twitter'),
                      ),
                    ],
                  ),

                  if (_isEditing && _availableSocialMediaTypes.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: _buildAddButton(
                      'Добавить социальную сеть', 
                      () {      
                        setState(() => _showAddSocialMedia = true);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final context = _socialFormKey.currentContext;
                          if (context != null) {
                            Scrollable.ensureVisible(
                              context,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        }); 
                      }
                    ),
                  ),

                  if (_showAddSocialMedia && _isEditing)
                  Padding(
                    key: _socialFormKey,
                    padding: EdgeInsets.only(top: 16),
                    child: _buildAddInfoForm(
                      isSocial: true,
                      types: _availableSocialMediaTypes,
                      onTypeSelected: (type) => _selectedSocialMediaType = type,
                      onAddPressed: _addSocialMedia,
                      onCancel: () => setState(() => _showAddSocialMedia = false),
                      controller: _socialMediaController,
                    ),
                  ),

                  const SizedBox(height: 16,),

                  //Шаблоны
                  if(!_isEditing) ...[
                    const Text(
                    'Предпросмотр вашей визитки',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                    const SizedBox(height: 16,),

                    _selectedCardTemplate == null
                    ? Center(
                        child: Opacity(
                          opacity: 0.2,
                          child: Icon(
                            Icons.credit_card,
                            size: MediaQuery.of(context).size.width * 0.45,
                            color: Colors.grey.shade400,
                          ),
                        )
                      )
                      : VisitCard1(
                          fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Иван Иванов',
                          position: _positionController.text.trim().isNotEmpty ? _positionController.text.trim() : 'Менеджер',
                          company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : 'Компания X',
                          socialLinks: linkWidgets,
                          template: _selectedCardTemplate!,
                          avatar: avatar,
                          selectedImage: _selectedImage,
                        ),

                    const SizedBox(height: 12,),
                      
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final selected = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return DraggableScrollableSheet(
                                initialChildSize: 0.5,
                                minChildSize: 0.5,
                                maxChildSize: 0.9,
                                expand: false,
                                builder: (context, scrollController) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ListView(
                                            controller: scrollController,
                                            padding: const EdgeInsets.all(16),
                                            children: [
                                              GestureDetector(
                                                onTap: () => Navigator.pop(context, VisitCardTemplate.template1),
                                                child: VisitCard1(
                                                  fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Иван Иванов",
                                                  position: _positionController.text.trim().isNotEmpty ? _positionController.text.trim() : "Менеджер",
                                                  company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : "Компания X",
                                                  template: VisitCardTemplate.template1,
                                                  socialLinks: linkWidgets,
                                                  avatar: avatar,
                                                  selectedImage: _selectedImage,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              GestureDetector(
                                                onTap: () => Navigator.pop(context, VisitCardTemplate.template2),
                                                child: VisitCard1(
                                                  fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Иван Иванов",
                                                  position: _positionController.text.trim().isNotEmpty ? _positionController.text.trim() : "Менеджер",
                                                  company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : "Компания X",
                                                  template: VisitCardTemplate.template2,
                                                  socialLinks: linkWidgets,
                                                  avatar: avatar,
                                                  selectedImage: _selectedImage,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              GestureDetector(
                                                onTap: () => Navigator.pop(context, VisitCardTemplate.template3),
                                                child: VisitCard1(
                                                  fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Иван Иванов",
                                                  position: _positionController.text.trim().isNotEmpty ? _positionController.text.trim() : "Менеджер",
                                                  company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : "Компания X",
                                                  template: VisitCardTemplate.template3,
                                                  socialLinks: linkWidgets,
                                                  avatar: avatar,
                                                  selectedImage: _selectedImage,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              GestureDetector(
                                                onTap: () => Navigator.pop(context, VisitCardTemplate.template4),
                                                child: VisitCard1(
                                                  fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Иван Иванов",
                                                  position: _positionController.text.trim().isNotEmpty ? _positionController.text.trim() : "Менеджер",
                                                  company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : "Компания X",
                                                  template: VisitCardTemplate.template4,
                                                  socialLinks: linkWidgets,
                                                  avatar: avatar,
                                                  selectedImage: _selectedImage,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                          if (selected != null) {
                            setState(() {
                              _selectedCardTemplate = selected;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C1A1F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Выбор шаблона визитки',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: (){
          setState(() {
            _showQrCode = !_showQrCode;
          });
        },
        fillColor: Color(0xFF784BF7),
        shape: CircleBorder(),
        constraints: BoxConstraints.tight(Size(50,50)),
        child: Icon(IonIcons.qr_code, color: Colors.white,),
      ),
    );
  }


  Widget _editableText(
    double sizeFont, {
    bool isBold = true,
    bool isCentered = true,
    VoidCallback? onEditPressed,
    required TextEditingController controller,
  }) {
    return Row(
      mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _isEditing
            ? IntrinsicWidth(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: sizeFont,
                    color: Colors.white,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w200,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    // border: InputBorder.none,
                  ),
                ),
              )
            : Text(
                controller.text,
                style: TextStyle(
                  fontSize: sizeFont,
                  color: Colors.white,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w200,
                ),
              ),
        if (_isEditing) ...[
          SizedBox(width: 6),
          GestureDetector(
            onTap: onEditPressed,
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ],
    );
  }


  Widget _editableAvatar() {
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

  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1C1A1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget _buildInfoCardWithDelete({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        InfoCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
          fullWidth: true,
        ),
        if (_isEditing)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSocialCardWithDelete({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        InfoCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
        ),
        if (_isEditing)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddInfoForm({
    required List<String> types,
    required Function(String) onTypeSelected,
    required VoidCallback onAddPressed,
    required VoidCallback onCancel,
    required TextEditingController controller,
    bool isSocial = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF100E12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: isSocial ? 'Социальная сеть' : 'Тип информации',
              labelStyle: TextStyle(color: Colors.white),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white, width: 1)
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white, width: 0)
              )
            ),
            items: types.map((type) {
              String displayText;
              switch (type) {
                case 'email': displayText = 'Email'; break;
                case 'phone': displayText = 'Телефон'; break;
                case 'website': displayText = 'Сайт'; break;
                case 'telegram': displayText = 'Telegram'; break;
                case 'linkedin': displayText = 'LinkedIn'; break;
                case 'github': displayText = 'GitHub'; break;
                case 'twitter': displayText = 'Twitter'; break;
                default: displayText = type;
              }
              return DropdownMenuItem(
                value: type,
                child: Text(displayText, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                onTypeSelected(value!);
              });
              controller.clear();
            },
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          TextFormField(
            inputFormatters: [
              if(_selectedInfoType == 'phone') phoneMask,
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => _validateMainInput(value),
            cursorColor: Colors.white,
            controller: controller,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white, width: 1)
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white, width: 0)
              ),
              labelText: isSocial ? 'Ссылка на профиль' : 'Данные',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1C1A1F),
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 5),
                    Text('Отмена'),
                  ],
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: onAddPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1C1A1F),
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 5),
                    Text('Добавить'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditingScope extends InheritedWidget{
  final bool isEditing;

  const EditingScope({
    super.key,
    required this.isEditing,
    required super.child,
  });

  static EditingScope? of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<EditingScope>();
  }

  @override
  bool updateShouldNotify(EditingScope oldWidget){
    return isEditing != oldWidget.isEditing;
  }
}


class InfoCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool fullWidth;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    double cardWidth = fullWidth
        ? double.infinity
        : (MediaQuery.of(context).size.width - 21 * 2 - 13) / 2;

    return Container(
      width: cardWidth,
      height: 50,
      margin: EdgeInsets.only(bottom: fullWidth ? 8 : 0),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFF100E12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Color(0xFF989898),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContactInfo {
  String? email;
  String? phone;
  String? website;
  
  bool get isEmpty => email == null && phone == null && website == null;

  List<Map<String, dynamic>> toContactList(){
    final contacts = <Map<String, dynamic>>[];

    void addContact(String? body, String platform){
      if(body != null){
        contacts.add({
          'icon': platform.toLowerCase(),
          'name': platform,
          'description': body,
        });
      }
    }

    addContact(email, 'email');
    addContact(phone, 'phone');
    addContact(website, 'website');

    return contacts;
  }
}

class SocialMedia {
  String? telegram;
  String? linkedin;
  String? github;
  String? twitter;
  
  bool get isEmpty => telegram == null && linkedin == null && github == null && twitter == null;

  List<Map<String, dynamic>> toWidgetsList() {
    final widgets = <Map<String, dynamic>>[];
    
    void addWidget(String? url, String platform) {
      if (url != null) {
        widgets.add({
          'link': url,
          'icon': platform.toLowerCase(),
          'description': '$platform профиль',
          'name': platform,
        });
      }
    }
    
    addWidget(telegram, 'Telegram');
    addWidget(linkedin, 'LinkedIn');
    addWidget(github, 'GitHub');
    addWidget(twitter, 'Twitter');
    
    return widgets;
  }
}

class VisitCard1 extends StatefulWidget {
  final String fullName;
  final String position;
  final String company;
  final List<LinkWidget> socialLinks;
  final double avatarRadius;
  final String? avatar;
  final Color cardColor;
  final Color? placeholderColor;
  final VisitCardTemplate template;
  final File? selectedImage;

  VisitCard1({
    Key? key,
    required this.fullName,
    required this.position,
    required this.company,
    required this.socialLinks,
    this.avatarRadius = 48.0,
    this.avatar,
    this.cardColor = const Color.fromARGB(255, 0, 0, 0),
    this.placeholderColor,
    this.template = VisitCardTemplate.template1,
    this.selectedImage,
  }) : super(key: key);

  @override
  State<VisitCard1> createState() => _VisitCard1State();
}

class _VisitCard1State extends State<VisitCard1> {
  final baseUrl = dotenv.env['BASE_URL'];

  // Порядок приоритета для отображения соцсетей
  static const List<String> _prioritySocials = [
    'telegram',
    'github',
    'linkedin',
    'instagram',
    'twitter',
  ];

  // Маппинг названий соцсетей на иконки
  static const Map<String, IconData> _socialIcons = {
    'twitter': Bootstrap.twitter_x,
    'telegram': Bootstrap.telegram,
    'instagram': Bootstrap.instagram,
    'github': Bootstrap.github,
    'linkedin': Bootstrap.linkedin,
  };

  // Отфильтрованные и отсортированные по приоритету социальные ссылки
  List<LinkWidget> get _topSocialLinks {
    final filtered = widget.socialLinks.where((link) => 
      _prioritySocials.any((social) => 
        link.name.toLowerCase().contains(social))
    ).toList();

    filtered.sort((a, b) {
      final aIndex = _prioritySocials.indexWhere((social) => 
        a.name.toLowerCase().contains(social));
      final bIndex = _prioritySocials.indexWhere((social) => 
        b.name.toLowerCase().contains(social));
      return aIndex.compareTo(bIndex);
    });

    return filtered.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9, // одинаковая ширина
      child: AspectRatio(
        aspectRatio: 1.6, // фиксированное соотношение сторон
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _buildTemplate(context),
        ),
      ),
    );
  }

  Widget _buildTemplate(BuildContext context) {
    switch (widget.template) {
      case VisitCardTemplate.template1:
        return _buildTemplate1(context);
      case VisitCardTemplate.template2:
        return _buildTemplate2(context);
      case VisitCardTemplate.template3:
        return _buildTemplate3(context);
      case VisitCardTemplate.template4:
        return _buildTemplate4(context);
    }
  }

  // ---------------- Шаблон 1 ----------------
  Widget _buildTemplate1(BuildContext context) {
    final topLinks = _topSocialLinks;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Левая часть (аватар + соцсети)
            SizedBox(
              width: constraints.maxWidth * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 15),
                  ...topLinks.map((link) {
                    final icon = _socialIcons.entries.firstWhere(
                      (entry) => link.name.toLowerCase().contains(entry.key),
                      orElse: () => _socialIcons.entries.first,
                    ).value;
                    return SocialLinkWidget(icon: icon, link: link.link);
                  }),
                ],
              ),
            ),

            // Правая часть (текст + QR)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.fullName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.position,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FontAwesome.building,
                            size: 20, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(widget.company,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w300)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    QrImageView(
                      data: 'https://example.com/qr',
                      version: QrVersions.auto,
                      size: 80,
                      gapless: false,
                      backgroundColor: Colors.white,
                      embeddedImage:
                          const AssetImage('assets/icons/LogoNight.png'),
                      embeddedImageStyle:
                          const QrEmbeddedImageStyle(size: Size(32, 19)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------- Шаблон 2 ----------------
  Widget _buildTemplate2(BuildContext context) {
    final topLinks = _topSocialLinks;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            //Левая часть (текст + QR)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.fullName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.position,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FontAwesome.building,
                            size: 20, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(widget.company,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w300)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    QrImageView(
                      data: 'https://example.com/qr',
                      version: QrVersions.auto,
                      size: 80,
                      gapless: false,
                      backgroundColor: Colors.white,
                      embeddedImage:
                          const AssetImage('assets/icons/LogoNight.png'),
                      embeddedImageStyle:
                          const QrEmbeddedImageStyle(size: Size(32, 19)),
                    ),
                  ],
                ),
              ),
            ),

            // Правая часть (аватар + соцсети)
            SizedBox(
              width: constraints.maxWidth * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 15),
                  ...topLinks.map((link) {
                    final icon = _socialIcons.entries.firstWhere(
                      (entry) => link.name.toLowerCase().contains(entry.key),
                      orElse: () => _socialIcons.entries.first,
                    ).value;
                    return SocialLinkWidget(icon: icon, link: link.link);
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------- Шаблон 3 ----------------
  Widget _buildTemplate3(BuildContext context) {
    final topLinks = _topSocialLinks;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.position,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesome.building,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.company,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //Ссылка в правом нижнем углу
            if(topLinks.isNotEmpty)
            Positioned(
              right: 8,
              bottom: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _socialIcons[topLinks[0].icon]!,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      topLinks[0].link,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  // ---------------- Шаблон 4 ----------------
  Widget _buildTemplate4(BuildContext context) {
  final topLinks = _topSocialLinks;

  return Center(
    child: IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch, // чтобы Divider тянулся
        children: [
          // Имя
          Align(
            alignment: Alignment.center,
            child: _buildNameWithLineBreak(widget.fullName),
          ),
          const SizedBox(width: 10),

          // Divider автоматически подстроится под высоту
          VerticalDivider(
            color: Colors.white,
            thickness: 2,
            width: 2,
          ),
          const SizedBox(width: 10),

          // Список ссылок
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: topLinks.map((link) {
              final icon = _socialIcons.entries.firstWhere(
                (entry) => link.name.toLowerCase().contains(entry.key),
                orElse: () => _socialIcons.entries.first,
              ).value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          link.link,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.selectedImage != null
          ? CircleAvatar(
            radius: 55,
            backgroundImage: FileImage(widget.selectedImage!),
          )
          : widget.avatar != null
            ? CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage('$baseUrl${widget.avatar}'),
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
      ],
    );
  }


  Widget _buildNameWithLineBreak(String fullName) {
    final trimmedName = fullName.trim();
    final names = trimmedName.split(' ');
    
    if (names.length > 1) {
      final firstName = names[0];
      final lastName = names.sublist(1).join(' ');
      
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              firstName, 
              style: TextStyle(
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              lastName, 
              style: TextStyle(
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } else {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 120),
        child: Text(
          trimmedName, 
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }
}

