import 'dart:convert';
import 'dart:math';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/share_visit.dart';
import 'package:connect_card/screens/visit_card_designer.dart';
import 'package:connect_card/screens/visit_card_profile.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class ListOfVisitCard extends StatefulWidget{
  const ListOfVisitCard({super.key});

  @override
  State<ListOfVisitCard> createState() => _ListOfVisitCardState();
}

class _ListOfVisitCardState extends State<ListOfVisitCard> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'];
  String? selectedCardId;
  String? _token;
  String? _id;
  bool _isPremiusUser = false;
  Map<String, String> get headers {
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }

  List<BusinessCard> cards = [];
  bool isLoading = true;
  bool isCardsEmpty = false;

  @override
  void initState(){
    super.initState();
    _initializeData();
  }

  void _showCustomDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Закрыть',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 20,
              title: Text(
                'Куда перейти?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogButton(
                    context,
                    Icons.dashboard,
                    'Обычное',
                    Colors.blueAccent,
                    () {
                      Navigator.pop(context);
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (_) => VisitCardProfile()));
                    },
                  ),
                  SizedBox(height: 12),
                  _buildDialogButton(
                    context,
                    // isActive: _isPremiusUser,
                    // isPremium: !_isPremiusUser,
                    isActive: true,
                    isPremium: false,
                    Icons.view_quilt,
                    'Дизайнер',
                    Colors.purpleAccent,
                    () {
                      Navigator.pop(context);
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (_) => VisitCardDesigner()));
                    },
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey[700], height: 1),
                  SizedBox(height: 12),
                  _buildCancelButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _initializeData() async{
    await _loadCredentials();
    await _checkPremium(); //Надо будет переделать
    await _loadCards();
  }

  Future<void> _loadCredentials() async {
    _id = await storage.read(key: 'id');
    _token = await storage.read(key: 'token');
  }

  //Временное решение
  Future<void> _checkPremium() async {
    final url = Uri.parse('$baseUrl/auth/current_user');
    try{
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
        }
      );
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        _isPremiusUser = user.isPremiumUser;

      }else{
        SnackbarHelper.showMessage(context, 'Извините, произошла ошибка');
      }
    }catch (e){
      print(e);
      SnackbarHelper.showMessage(context, 'Произошла ошибка сети $e', isSuccess: false);
    }
  }

  Future<void> _loadCards() async { 
    final response = await http.get(
      Uri.parse('$baseUrl/cards/user/$_id'),
      headers: headers,
    );
    if(response.statusCode == 404){
      setState(() {
        isLoading = false;
        isCardsEmpty = true;
      });
    }else if(response.statusCode == 200){
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      if(jsonData.isEmpty){
        setState(() {
          isLoading = false;
          isCardsEmpty = true;
        });
      }else{
        setState(() {
          cards = jsonData.map((e) => BusinessCard.fromJson(e as Map<String, dynamic>)).toList();
          isLoading = false;
        });
      }
    }else{
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка', isSuccess: false);
    }
  }

  Future<void> _deleteCard(String cardId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cards/$cardId'),
      headers: headers,
    );
    if(response.statusCode == 200){
      SnackbarHelper.showMessage(context, 'Визитка успешно удалена');
      _loadCards();
    }else{
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка при удалении', isSuccess: false);
    }
  }

  void showConfirmDeleteDialog(BuildContext context, String index) {

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
                Icon(Icons.delete, size: 40, color: Colors.blueAccent),
                SizedBox(height: 16),
                Text(
                  'Вы действительно хотите удалить визитку?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // print('Пользователь пропустил');
                      },
                      child: Text(
                        'Нет',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteCard(index);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Удалить',
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

  void _showCardContextMenu(BuildContext context, Offset position, String index) async {
    setState(() {
      selectedCardId = index;
    });

    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, 0),
      items: [
        PopupMenuItem(
          value: 'share',
          child: ListTile(
            leading: Icon(Bootstrap.share_fill),
            title: Text('Поделиться'),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Удалить'),
          ),
        ),
      ],
    );

    setState(() {
      selectedCardId = null;
    });

    if (selected == 'share') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ShareVisit(cardId: index,)));
    } else if (selected == 'delete') {
      showConfirmDeleteDialog(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141218),
      body: Column(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(
                        child: Text(
                          'Ваши Визитки',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            _showCustomDialog(context);
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => VisitCardProfile()))
                            // .then((_){
                            //   if(mounted) _loadCards();
                            // });
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VisitCardDesigner()));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 1,
                  height: 0,
                  indent: 20,
                  endIndent: 20,
                ),
              ],
            ),
          ),
          if (isCardsEmpty)
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                        'Создай свою визитку',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нажми на кнопку "+" выше',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      ],
                    ),
                  )
                ],
              )
            ),
          if (!isCardsEmpty) ...[
            const SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            final isSelected = selectedCardId == card.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 25),
                              child: GestureDetector(
                                onLongPressStart: (details) {
                                  _showCardContextMenu(context, details.globalPosition, card.id);
                                },
                                child: Opacity(
                                  opacity: selectedCardId == null || isSelected ? 1.0 : 0.5,
                                  child: card.elements.length > 0
                                  ? VisitCardRenderDesign(elements: card.elements)
                                  : VisitCard1(
                                    fullName: card.fullname,
                                    position: card.position ?? '',
                                    company: card.company ?? '',
                                    socialLinks: card.linkWidgets,
                                    isSelected: isSelected,
                                    avatar: card.avatar,
                                    isList: true,
                                    template: VisitCardTemplate.fromString(card.template),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (selectedCardId != null)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCardId = null;
                                });
                              },
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                      ],
                    ),
                  ),
          ],
        ],
      ),
    );
  }

  Widget _buildDialogButton(BuildContext context, IconData icon, 
                          String text, Color color, VoidCallback onTap,
                          {bool isActive = true, bool isPremium = false}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(isActive ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isActive ? 0.3 : 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, 
                  color: color.withOpacity(isActive ? 1.0 : 0.5), 
                  size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            color: Colors.white.withOpacity(isActive ? 1.0 : 0.6),
                            fontSize: 16,
                            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                        if (isPremium) ...[
                          const SizedBox(width: 8),
                          Icon(BoxIcons.bx_crown, 
                              size: 18, 
                              color: Colors.amberAccent.withOpacity(0.8))
                        ]
                      ],
                    ),
                    if (isPremium && !isActive)
                      Text(
                        'Только для Premium',
                        style: TextStyle(
                          color: Colors.amberAccent.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, 
                  color: color.withOpacity(isActive ? 0.7 : 0.3), 
                  size: 16),
            ],
          ),
        ),
      ),
    ),
  );
}


// Кнопка отмены
  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[400],
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      child: Text(
        'Отмена',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}


class VisitCard extends StatefulWidget {
  final String fullName;
  final String position;
  final String company;
  final List<LinkWidget> socialLinks;
  final String qrCodeAssetPath;
  final double avatarRadius;
  final String? avatar;
  final Color cardColor;
  final bool isSelected;
  final Color? placeholderColor;


  const VisitCard({
    Key? key,
    required this.fullName,
    required this.position,
    required this.company,
    required this.socialLinks,
    this.isSelected = false,
    this.qrCodeAssetPath = 'assets/icons/qr_code.png',
    this.avatarRadius = 48.0,
    this.avatar,
    this.cardColor = const Color(0xFF1B1A20),
    this.placeholderColor,
  }) : super(key: key);

  @override
  _VisitCardState createState() => _VisitCardState();
}

class _VisitCardState extends State<VisitCard> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  final baseUrl = dotenv.env['BASE_URL'];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    
    _glowAnimation = Tween(begin: 0.05, end: 0.2).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.isSelected) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VisitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

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
    final topLinks = _topSocialLinks;
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return FractionallySizedBox(
          widthFactor: 0.9,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(_glowAnimation.value * 2),
                width: widget.isSelected ? 3 : 2,
              ),
              boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(_glowAnimation.value),
                      blurRadius: 10 + _glowAnimation.value * 20,
                      spreadRadius: 0,
                    ),
                    // BoxShadow(
                    //   color: Colors.white.withOpacity(_glowAnimation.value * 0.7),
                    //   blurRadius: 30,
                    //   spreadRadius: 10,
                    // ),
                  ]
                : null,
            ),
            child: child,
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Левая часть с аватаром и ссылками
              Container(
                width: constraints.maxWidth * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: _buildAvatar(),
                    ),
                    SizedBox(height: 15),
                    ...List.generate(3, (i) {
                      if (i < topLinks.length) {
                        final link = topLinks[i];
                        final icon = _socialIcons.entries.firstWhere(
                          (entry) => link.name.toLowerCase().contains(entry.key),
                          orElse: () => _socialIcons.entries.first
                        ).value;
                        
                        return SocialLinkWidget(
                          icon: icon,
                          link: link.link,
                        );
                      }
                      return SizedBox(height: 0);
                    }),
                  ],
                ),
              ),
              
              // Правая часть
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            Text(widget.fullName, 
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold)),
                            Text(widget.position, 
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w300)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(FontAwesome.building, size: 20, color: Colors.white),
                                SizedBox(width: 4),
                                Text(widget.company, 
                                  style: TextStyle(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w300
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      QrImageView(
                        data: '$baseUrl/cards/6/qr-link',
                        version: QrVersions.auto,
                        size: 80,
                        gapless: false,
                        backgroundColor: Colors.white,
                        embeddedImage: AssetImage('assets/icons/LogoNight.png'),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: Size(32, 19),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.avatar == null || widget.avatar!.isEmpty) {
      return CircleAvatar(
        radius: widget.avatarRadius,
        backgroundColor: widget.placeholderColor ?? Colors.grey[300],
        child: Icon(
          Icons.person,
          size: widget.avatarRadius,
          color: Colors.white,
        ),
      );
    }

    return CircleAvatar(
      radius: widget.avatarRadius,
      backgroundImage: NetworkImage('$baseUrl${widget.avatar!}'),
      onBackgroundImageError: (exception, stackTrace) {
        //error
      },
    );
  }
}

class SocialLinkWidget extends StatelessWidget {
  final IconData icon;
  final String link;

  const SocialLinkWidget({
    required this.icon,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          Icon(icon, size: 14),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              link,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w300
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class VisitCardRenderDesign extends StatelessWidget {
  final List<CardElement> elements;

  final Map<String, FontWeight> fontWeightMap = {
    'normal': FontWeight.normal,
    'bold': FontWeight.bold,
    'w100': FontWeight.w100,
    'w200': FontWeight.w200,
    'w300': FontWeight.w300,
    'w400': FontWeight.w400,
    'w500': FontWeight.w500,
    'w600': FontWeight.w600,
    'w700': FontWeight.w700,
    'w800': FontWeight.w800,
    'w900': FontWeight.w900,
  };

  VisitCardRenderDesign({Key? key, required this.elements});
  final baseUrl = dotenv.env['BASE_URL'];

  Color parseColor(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    int colorValue = int.parse(hexColor, radix: 16);
    return Color(colorValue);
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20), //Посмотреть и подшаманить
      child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blueAccent, Colors.purpleAccent],
                ),
              ),
            ),
          ),
          ...elements.map((e) => _buildElement(e)),
        ],
      ),
    ),

    );
  }

Widget _buildElement(CardElement element) {
  return OverflowBox(
    minWidth: 0,
    minHeight: 0,
    maxWidth: double.infinity,
    maxHeight: double.infinity,
    child: Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..multiply(element.matrix)
        ..rotateZ(element.rotationAngle * pi / 180),
      child: _buildElementWidget(element),
    ),
  );
}



  Widget _buildElementWidget(CardElement element) {
    ElementType type = ElementType.values.firstWhere(
      (e) => e.toString().split('.').last == element.type,
      orElse: () => ElementType.text,
    );

    final color = parseColor(type == ElementType.text ? element.textColor! : element.color!);
    
    switch (type) {
      case ElementType.text:
        return Text(
          element.text ?? '',
          style: TextStyle(
            fontSize: element.fontSize?.toDouble() ?? element.baseFontSize?.toDouble() ?? 18,
            fontFamily: element.fontFamily,
            color: element.textColor != null 
                ? color 
                : Colors.black,
            fontWeight: fontWeightMap[element.fontWeight],
          ),
        );
      
      case ElementType.image:
        return Opacity(
          opacity: element.imageOpacity,
          child: Container(
            width: element.width,
            height: element.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('$baseUrl${element.imageUrl}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
        // return Container(
        //   width: element.width.toDouble(),
        //   height: element.height,
        //   color: element.color != null 
        //       ? color
        //       : Colors.grey,
        //   child: Image.network('$baseUrl${element.imageUrl}'),
        // );
      
      case ElementType.shape:
        ShapeType shapeType = ShapeType.values.firstWhere(
          (e) => e.toString().split('.').last == element.shapeType,
          orElse: () => ShapeType.circle,
        );
        return Container(
          width: element.width.toDouble(),
          height: element.height.toDouble(),
          child: CustomPaint(
            painter: ShapePainter(
              shapeType: shapeType,
              color: color!),
          ),
        );
      
      default:
        return Container();
    }
  }
}