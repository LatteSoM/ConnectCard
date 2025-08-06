import 'dart:convert';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/share_visit.dart';
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

  Future<void> _initializeData() async{
    await _loadCredentials();
    await _loadCards();
  }

  Future<void> _loadCredentials() async {
    _id = await storage.read(key: 'id');
    _token = await storage.read(key: 'token');
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
      _deleteCard(index);
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => VisitCardProfile()))
                            .then((_){
                              if(mounted) _loadCards();
                            });
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
                                  child: VisitCard(
                                    fullName: card.fullname,
                                    position: card.position ?? '',
                                    company: card.company ?? '',
                                    socialLinks: card.linkWidgets,
                                    isSelected: isSelected,
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
}


class VisitCard extends StatefulWidget {
  final String fullName;
  final String position;
  final String company;
  final List<LinkWidget> socialLinks;
  final String qrCodeAssetPath;
  final double avatarRadius;
  final Color cardColor;
  final bool isSelected;


  const VisitCard({
    Key? key,
    required this.fullName,
    required this.position,
    required this.company,
    required this.socialLinks,
    this.isSelected = false,
    this.qrCodeAssetPath = 'assets/icons/qr_code.png',
    this.avatarRadius = 48.0,
    this.cardColor = const Color(0xFF1B1A20),
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
    'instagram',
    'twitter',
    'github',
    'linkedin',
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
                      child: CircleAvatar(radius: widget.avatarRadius),
                    ),
                    SizedBox(height: 15),
                    ...List.generate(3, (i) {
                      if (i < topLinks.length) {
                        final link = topLinks[i];
                        final icon = _socialIcons.entries.firstWhere(
                          (entry) => link.name.toLowerCase().contains(entry.key),
                          orElse: () => _socialIcons.entries.first
                        ).value;
                        
                        return _SocialLinkWidget(
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
}

class _SocialLinkWidget extends StatelessWidget {
  final IconData icon;
  final String link;

  const _SocialLinkWidget({
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