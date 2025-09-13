import 'package:connect_card/screens/visit_card_profile.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

class CardPreviewPage extends StatefulWidget {
  final VisitCard1 visitCard;
  const CardPreviewPage({super.key, required this.visitCard});

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

  @override
  void initState() {
    super.initState();
    // Контроллер для подпрыгивания карточки и движения частиц
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
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

            // Частицы
            _buildParticles(constraints),

            // Контент
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
                              page: FullCardPage(visitCard: widget.visitCard)),
                        );
                      },
                      child: widget.visitCard,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Текст
                  FadeTransition(
                    opacity: Tween(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
                    ),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                          scheme: 'mailto',
                        ),
                      if (visitCard.contactInfos.any((item) => item.name == 'phone'))
                        _buildInfoCard(
                          icon: Icon(Icons.phone, color: Colors.white, size: 32),
                          title: "Телефон",
                          subtitle: visitCard.contactInfos.firstWhere((item) => item.name == 'phone').description!,
                          scheme: 'tel'
                        ),
                      if (visitCard.contactInfos.any((item) => item.name == 'website'))
                        _buildInfoCard(
                          icon: Icon(Icons.language, color: Colors.white, size: 32),
                          title: "Сайт",
                          subtitle: visitCard.contactInfos.firstWhere((item) => item.name == 'website').description!,
                          scheme: 'https'
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
                      ),
                      if (visitCard.socialLinks.any((item) => item.name == 'LinkedIn'))
                      _buildSocialCard(
                        icon: Icon(EvaIcons.linkedin, color: Colors.white, size: 24),
                        title: "LinkedIn",
                        subtitle: visitCard.socialLinks.firstWhere((item) => item.name == 'LinkedIn').link,
                      ),
                      if (visitCard.socialLinks.any((item) => item.name == 'GitHub'))
                      _buildSocialCard(
                        icon: Icon(Bootstrap.github, color: Colors.white, size: 24),
                        title: "GitHub",
                        subtitle: visitCard.socialLinks.firstWhere((item) => item.name == 'GitHub').link,
                      ),
                      if (visitCard.socialLinks.any((item) => item.name == 'Twitter'))
                      _buildSocialCard(
                        icon: Icon(Bootstrap.twitter_x, color: Colors.white, size: 24),
                        title: "X",
                        subtitle: visitCard.socialLinks.firstWhere((item) => item.name == 'Twitter').link,
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
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 55,
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
    String scheme = '',
  }) {
    return Stack(
      children: [
        InfoCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
          fullWidth: true,
          scheme: scheme,
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
