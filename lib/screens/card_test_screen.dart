import 'dart:convert';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/visit_card_profile.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher.dart';

class CardPreviewPage extends StatefulWidget {
  final String cardId;
  const CardPreviewPage({super.key, required this.cardId});

  @override
  State<CardPreviewPage> createState() => _CardPreviewPageState();
}

class _CardPreviewPageState extends State<CardPreviewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final int _numParticles = 25;
  late List<_Particle> _particles;
  bool _initialized = false;
  double _screenWidth = 0;
  double _screenHeight = 0;

  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'];

  String? _token;

  Map<String, String> get headers {
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }

  BusinessCard? card;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Контроллер для подпрыгивания карточки и движения частиц
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  Future<void> _initializeData() async{
    await _loadCredentials();
    await loadCard();
  }

  Future<void> loadCard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cards/${widget.cardId}'),
      headers: headers
    );

    if(response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      setState(() {
        card = BusinessCard.fromJson(jsonData);
      });
    } else {
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка', isSuccess: false);
    }
  }

  Future<void> _loadCredentials() async {
    _token = await storage.read(key: 'token');
  }

  void _initParticles(BoxConstraints constraints) {
    if (!_initialized) {
      _screenWidth = constraints.maxWidth;
      _screenHeight = constraints.maxHeight;
      _particles = List.generate(
        _numParticles,
        (_) => _Particle.random(_random, _screenWidth, _screenHeight),
      );
      _initialized = true;
    }
  }

  Widget _buildParticles(BoxConstraints constraints) {
    _initParticles(constraints);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final dt = 1 / 60;
        return Stack(
          children: _particles.map((p) {
            p.update(dt, _screenWidth, _screenHeight);
            return Positioned(
              left: p.x,
              top: p.y,
              child: Container(
                width: p.size,
                height: p.size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(p.opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            // Фон
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade900, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            _buildParticles(constraints),

            if (card != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Подпрыгивающая карточка
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        double lift = sin(_controller.value * 2 * pi) * 6;
                        return Transform.translate(
                          offset: Offset(0, -lift),
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            ScalePageRoute(
                              page: FullCardPage(
                                visitCard: VisitCard1(
                                  fullName: card!.fullname,
                                  position: card!.position ?? '',
                                  company: card!.company ?? '',
                                  socialLinks: card!.linkWidgets,
                                  contactInfos: card!.contactInfos,
                                  avatar: card!.avatar ?? '',
                                ),
                              ),
                            ),
                          );
                        },
                        child: VisitCard1(
                          fullName: card!.fullname,
                          position: card!.position ?? '',
                          company: card!.company ?? '',
                          socialLinks: card!.linkWidgets,
                          contactInfos: card!.contactInfos,
                          avatar: card!.avatar ?? '',
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Текст
                    FadeTransition(
                      opacity: Tween(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(parent: _controller, curve: Curves.easeIn),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Нажмите, чтобы увидеть подробную информацию',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Индикатор загрузки или сообщение, если карточка еще не загружена
            if (card == null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Загрузка карточки...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Класс частицы
class _Particle {
  double x;
  double y;
  final double size;
  final double opacity;
  double vx;
  double vy;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.vx,
    required this.vy,
  });

  factory _Particle.random(Random random, double width, double height) {
    double speed = 10 + random.nextDouble() * 20;
    double angle = random.nextDouble() * 2 * pi;
    return _Particle(
      x: random.nextDouble() * width,
      y: random.nextDouble() * height,
      size: 3.0 + random.nextDouble() * 4,
      opacity: 0.15 + random.nextDouble() * 0.3,
      vx: cos(angle) * speed / 60,
      vy: sin(angle) * speed / 60,
    );
  }

  void update(double dt, double width, double height) {
    x += vx;
    y += vy;

    if (x < 0) x += width;
    if (x > width) x -= width;
    if (y < 0) y += height;
    if (y > height) y -= height;
  }
}


class FullCardPage extends StatelessWidget {
  final VisitCard1 visitCard;
  const FullCardPage({super.key, required this.visitCard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: EditingScope(
            isEditing: false,
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: BackButton(
                        color: Colors.purpleAccent,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                      ),
                  //Аватарка
                  _buildAvatar(),
                  const SizedBox(height: 16,),
                  //Имя
                  _editableText(
                    18,
                    text: visitCard.fullName,
                  ),

                  const SizedBox(height: 7,),

                  //Должность
                  _editableText(
                    18,
                    text: visitCard.position,
                  ),

                  const SizedBox(height: 8,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesome.building, color: Colors.white, size: 24,),
                      SizedBox(width: 5,),
                      //Организация
                      _editableText(
                        18,
                        text: visitCard.company,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28,),

                  //О Себе
                  _editableText(
                    18,
                    text: '',
                  ),

                  const SizedBox(height: 25,),
                  Text("Связаться со мной", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),

                  SizedBox(height: 16),

                  Column(
                    children: [
                      if (visitCard.contactInfos.any((item) => item.name == 'email'))
                        _buildInfoCard(
                          icon: Icon(Icons.email_outlined, color: Colors.white, size: 32),
                          title: "Email",
                          subtitle: visitCard.contactInfos.firstWhere((item) => item.name == 'email').description!,
                          shareType: ShareType.email,
                        ),
                      if (visitCard.contactInfos.any((item) => item.name == 'phone'))
                        _buildInfoCard(
                          icon: Icon(Icons.phone, color: Colors.white, size: 32),
                          title: "Телефон",
                          subtitle: visitCard.contactInfos.firstWhere((item) => item.name == 'phone').description!,
                          shareType: ShareType.phone,
                        ),
                      if (visitCard.contactInfos.any((item) => item.name == 'website'))
                        _buildInfoCard(
                          icon: Icon(Icons.language, color: Colors.white, size: 32),
                          title: "Сайт",
                          subtitle: visitCard.contactInfos.firstWhere((item) => item.name == 'website').description!,
                          shareType: ShareType.website
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
                      if (visitCard.socialLinks.any((item) => item.name == 'Telegram'))
                      _buildSocialCard(
                        icon: Icon(BoxIcons.bxl_telegram, color: Colors.white, size: 24),
                        title: "Телеграм",
                        subtitle: visitCard.socialLinks.firstWhere((item) => item.name == 'Telegram').link,
                        shareType: ShareType.telegram,
                      ),
                      if (visitCard.socialLinks.any((item) => item.name == 'LinkedIn'))
                      _buildSocialCard(
                        icon: Icon(EvaIcons.linkedin, color: Colors.white, size: 24),
                        title: "LinkedIn",
                        subtitle: visitCard.socialLinks.firstWhere((item) => item.name == 'LinkedIn').link,
                        shareType: ShareType.linkedin,
                      ),
                      if (visitCard.socialLinks.any((item) => item.name == 'GitHub'))
                      _buildSocialCard(
                        icon: Icon(Bootstrap.github, color: Colors.white, size: 24),
                        title: "GitHub",
                        subtitle: visitCard.socialLinks.firstWhere((item) => item.name == 'GitHub').link,
                        shareType: ShareType.github,
                      ),
                      if (visitCard.socialLinks.any((item) => item.name == 'Twitter'))
                      _buildSocialCard(
                        icon: Icon(Bootstrap.twitter_x, color: Colors.white, size: 24),
                        title: "X",
                        subtitle: visitCard.socialLinks.firstWhere((item) => item.name == 'Twitter').link,
                        shareType: ShareType.twitter,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16,),
                ],
              ),
            ),
          ),
        ),
              );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        visitCard.avatar != null
            ? CircleAvatar(
              radius: 52,
              backgroundImage: NetworkImage('$baseUrl${visitCard.avatar}'),
              onBackgroundImageError: (exception, stackTrace) {

              },
            )
            : CircleAvatar(
              radius: 52,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 52,
                color: Colors.white,
              ),
            ),
      ],
    );
  }

  Widget _editableText(
    double sizeFont, {
    bool isBold = true,
    bool isCentered = true,
    required String text,
  }) {
    return Row(
      mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: sizeFont,
            color: Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w200,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required ShareType shareType,
  }) {
    return Stack(
      children: [
        InfoCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
          fullWidth: true,
          shareType: shareType,
        ),
      ],
    );
  }

  Widget _buildSocialCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required ShareType shareType,
  }) {
    return Stack(
      children: [
        InfoCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
          shareType: shareType,
        ),
      ],
    );
  }
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeInOut;

            var scaleAnimation = Tween<double>(begin: 0.9, end: 1.0)
                .chain(CurveTween(curve: curve))
                .animate(animation);

            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: curve))
                .animate(animation);

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        );
}
