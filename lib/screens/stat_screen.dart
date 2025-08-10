import 'dart:async';
import 'dart:convert';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';

class StatScreen extends StatefulWidget{
  // final String cardId;
  // const StatScreen({super.key, required this.cardId});
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen>{
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

  StatCard statCard = StatCard.empty();
  bool _isLoading = false;
  bool _isAnalyticEmpty = false;

  @override
  void initState() {
    super.initState();
    ViewsByDevice testDevices = ViewsByDevice(
      desktop: 100,
      mobile: 200,
      tablet: 20
    );
    List<PopularLinks> popular_links = [
      PopularLinks(linkWidgetId: '', name: 'Telegram', clicks: 10),
      PopularLinks(linkWidgetId: '', name: 'GitHub', clicks: 20),
    ];
    TopActions topActions = TopActions(
      view: 100,
      linkClick: 12,
      share: 50,
      addToContacts: 25
    );
    StatCard testCard = StatCard(
      cardId: '',
      totalViews: 200000,
      totalShares: 150,
      totalAddToContacts: 50,
      conversionRate: 5.55,
      viewsByDevice: testDevices,
      popularLinks: popular_links,
      topActions: topActions
    );
    setState(() {
      statCard = testCard;
    });
    // _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadCredentials();
    await _loadAnalytics();
  }

  Future<void> _loadCredentials() async {
    _id = await storage.read(key: 'id');
    _token = await storage.read(key: 'token');
  }

  Future<void> _loadAnalytics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics'),
      headers: headers,
    );

    if(response.statusCode == 200){
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      if(jsonData.isEmpty) {
        setState(() {
          _isLoading = false;
          _isAnalyticEmpty = true;
        });
      }else {
        setState(() {
          statCard = StatCard.fromJson(jsonData);
          _isLoading = false;
        });
      }
    }else{
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка', isSuccess: false);
    }
  }

  IconData _getIconForService(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'telegram':
        return BoxIcons.bxl_telegram;
      case 'linkedin':
        return EvaIcons.linkedin;
      case 'github':
        return Bootstrap.github;
      case 'twitter':
        return BoxIcons.bxl_twitter;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'website':
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Column(
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Аналитика',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isAnalyticEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Статистика отсутствует',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Делитесь своей визиткой с другими,\nчтобы увидеть здесь статистику',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Icon(
                          Icons.insights,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // AnimatedVisibilityCard(
                        //   visibilityKey: const Key('top_stats'),
                        //   child: TopStatsCard(
                        //   totalViews: statCard.totalViews,
                        //   totalShares: statCard.totalShares,
                        //   conversionRate: statCard.conversionRate),
                        //   ),
                        TopStatsCard(
                          totalViews: statCard.totalViews,
                          totalShares: statCard.totalShares,
                          conversionRate: statCard.conversionRate),
                        // _buildTopStats(),
                        const SizedBox(height: 16),
                        // _buildPopularTransitions(),
                        // AnimatedVisibilityCard(
                        //   visibilityKey: const Key('popular_transitions'),
                        //   child: PopularTransitionsCard(popularLinks: statCard.popularLinks),
                        //   ),
                        PopularTransitionsCard(popularLinks: statCard.popularLinks),
                        const SizedBox(height: 16),
                        // _buildDeviceUsage(),
                        // AnimatedVisibilityCard(
                        //   visibilityKey: const Key('device_usage'),
                        //   child: DeviceUsageCard(mobile: statCard.viewsByDevice.mobile, desktop: statCard.viewsByDevice.desktop, tablet: statCard.viewsByDevice.tablet),
                        //   ),
                        DeviceUsageCard(mobile: statCard.viewsByDevice.mobile, desktop: statCard.viewsByDevice.desktop, tablet: statCard.viewsByDevice.tablet),
                        const SizedBox(height: 16),
                        // _buildWeeklyViews(),
                        // AnimatedVisibilityCard(
                        //   visibilityKey: const Key('weekly_views'),
                        //   child: WeeklyViewsCard(
                        //   labels: ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'],
                        //   heightFactors: [0.6, 1.0, 0.5, 0.7, 0.9, 0.8, 0.3],
                        // ),
                        //   ),
                        WeeklyViewsCard(
                          labels: ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'],
                          heightFactors: [0.6, 1.0, 0.5, 0.7, 0.9, 0.8, 0.3],
                        ),
                        const SizedBox(height: 16),
                        AnimatedVisibilityCard(
                          visibilityKey: const Key('traffic_sources'),
                          child: _buildTrafficSources(),
                          ),
                        // _buildTrafficSources(),
                        const SizedBox(height: 16),
                        AnimatedVisibilityCard(
                          visibilityKey: const Key('top_actions'),
                          child: TopActionsCard(),
                          ),
                        // _buildTopActions(),
                        const SizedBox(height: 16),
                        AnimatedVisibilityCard(
                          visibilityKey: const Key('visit_card'),
                          child: _buildVisitStat(),
                          ),
                        // _buildVisitStat(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTopStats() {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          _statColumn('Просмотры', statCard.totalViews.toString(), '+112 с прошлой недели', Colors.green),
          _verticalDivider(),
          _statColumn('Репосты', statCard.totalShares.toString(), '+53 с прошлой недели', Colors.green),
          _verticalDivider(),
          _statColumn('Конверсия', '${statCard.conversionRate}%', '-0.5%', Colors.red),
        ],
      ),
    );
  }

  Widget _statColumn(String title, String value, String sub, Color subColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(color: subColor, fontSize: 8,)),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 60,
      color: Colors.grey[700],
    );
  }

  Widget _statCard(String title, String value, String sub, Color subColor) {
    return Expanded(
      child: Card(
        color: const Color(0xFF1E1E1E),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(sub, style: TextStyle(color: subColor, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularTransitions() {
    final sortedLinks = statCard.popularLinks..sort((a, b) => b.clicks.compareTo(a.clicks));
    final topLinks = sortedLinks.take(3).toList();

    return _sectionCard(
      title: 'Популярные переходы:',
      children: [
        if (topLinks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Нет данных о переходах'),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final link in topLinks) ...[
                _iconStat(_getIconForService(link.name), '${link.clicks}'),
                if (link != topLinks.last) _verticalDivider(),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildDeviceUsage() {
    final totalViews = statCard.viewsByDevice.desktop + 
                      statCard.viewsByDevice.mobile + 
                      statCard.viewsByDevice.tablet;

    double _calculatePercent(int value) {
      return totalViews > 0 ? value / totalViews : 0;
    }

    return _sectionCard(
      title: 'Устройства:',
      children: [
        _progressItem(
          'Мобильные', 
          statCard.viewsByDevice.mobile,
          _calculatePercent(statCard.viewsByDevice.mobile),
        ),
        _progressItem(
          'Десктоп', 
          statCard.viewsByDevice.desktop,
          _calculatePercent(statCard.viewsByDevice.desktop),
        ),
        _progressItem(
          'Планшеты', 
          statCard.viewsByDevice.tablet,
          _calculatePercent(statCard.viewsByDevice.tablet),
        ),
      ],
    );
  }

  Widget _buildWeeklyViews() {
    return _sectionCard(
      title: 'Просмотры за неделю:',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _barStat('пн', 0.6),
            _barStat('вт', 1.0),
            _barStat('ср', 0.5),
            _barStat('чт', 0.7),
            _barStat('пт', 0.9),
            _barStat('сб', 0.8),
            _barStat('вс', 0.3),
          ],
        )
      ],
    );
  }

  Widget _buildTrafficSources() {
  final trafficSources = [
    _TrafficSource('Прямые переходы', statCard.topActions.view),
    _TrafficSource('QR-коды', statCard.topActions.linkClick),
    _TrafficSource('Поделились', statCard.topActions.share),
    _TrafficSource('Добавили в контакты', statCard.topActions.addToContacts),
  ];

  trafficSources.sort((a, b) => b.value.compareTo(a.value));
  final topSources = trafficSources.take(3).toList();

  return TrafficSourcesCard(sources: topSources);
}


  Widget _buildTopActions() {
    return _sectionCard(
      title: 'Топ действий:',
      children: const [
        _actionItem(Icons.remove_red_eye, 'Просмотры', '78%'),
        Divider(thickness: 1, color: Colors.white, indent: 10, endIndent: 10,),
        _actionItem(Bootstrap.person_add, 'Добавление в контакты', '55%'),
        Divider(thickness: 1, color: Colors.white, indent: 10, endIndent: 10),
        _actionItem(OctIcons.share, 'Поделиться', '34%'),
      ],
    );
  }

Widget _buildVisitStat() {
  return VisitStatCard(
    image: "image",
    name: "Барак Обама",
    position: "Старший кассир",
    company: "ООО KFC",
    views: 551,
    adds: 782,
    shares: 144,
  );
}


  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _iconStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _iconStat(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}

class _progressItem extends StatelessWidget {
  final String label;
  final int value;
  final double percent;

  const _progressItem(this.label, this.value, this.percent);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
              Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            color: Colors.white,
            minHeight: 12,
            borderRadius: BorderRadius.all(Radius.circular(50)),
            backgroundColor: Color(0xFF8F8888),
          ),
        ],
      ),
    );
  }
}

class _barStat extends StatelessWidget {
  final String label;
  final double heightFactor;

  const _barStat(this.label, this.heightFactor);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 20,
              height: 100 * heightFactor,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 24,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _visitItem extends StatefulWidget {
  final String image;
  final String name;
  final String position;
  final String company;
  final int views;
  final int adds;
  final int shares;

  const _visitItem(this.image, this.name, this.position, this.company, this.views, this.adds, this.shares, {Key? key}) : super(key: key);

  @override
  State<_visitItem> createState() => _visitItemState();
}

class _visitItemState extends State<_visitItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animatedStatItem(IconData icon, int value) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1000),
      builder: (context, val, child) {
        return Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 11),
            Text('$val', style: const TextStyle(color: Colors.white)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 33,
                // Можно добавить изображение из widget.image, если нужно
                backgroundColor: Colors.grey[700],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(widget.position, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white)),
                    Text(widget.company, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 60,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  _animatedStatItem(Icons.remove_red_eye, widget.views),
                  const SizedBox(height: 5),
                  _animatedStatItem(Bootstrap.person_add, widget.adds),
                  const SizedBox(height: 5),
                  _animatedStatItem(OctIcons.share, widget.shares),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class _actionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String percent;

  const _actionItem(this.icon, this.title, this.percent);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32,),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
          Text(percent, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
        ],
      ),
    );
  }
}

class _TrafficSource {
  final String label;
  final int value;

  _TrafficSource(this.label, this.value);
}

//первое

class TopStatsCard extends StatefulWidget {
  final int totalViews;
  final int totalShares;
  final double conversionRate;

  const TopStatsCard({
    Key? key,
    required this.totalViews,
    required this.totalShares,
    required this.conversionRate,
  }) : super(key: key);

  @override
  State<TopStatsCard> createState() => _TopStatsCardState();
}

class _TopStatsCardState extends State<TopStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _views = 0;
  int _shares = 0;
  double _conversion = 0;

  @override
  void initState() {
    super.initState();

    // Анимация появления карточки
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2), // немного сверху
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Запуск анимаций после построения виджета
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();

      // Запускаем числа через 400 мс после старта появления
      Future.delayed(const Duration(milliseconds: 400), () {
        _animateNumbers();
      });
    });
  }

  void _animateNumbers() {
    // Плавная анимация чисел через Timer
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        if (_views < widget.totalViews) {
          _views += (widget.totalViews / 20).ceil();
          if (_views > widget.totalViews) _views = widget.totalViews;
        }
        if (_shares < widget.totalShares) {
          _shares += (widget.totalShares / 20).ceil();
          if (_shares > widget.totalShares) _shares = widget.totalShares;
        }
        if (_conversion < widget.conversionRate) {
          _conversion += widget.conversionRate / 20;
          if (_conversion > widget.conversionRate) {
            _conversion = widget.conversionRate;
          }
        }
      });

      // Останавливаем таймер, когда всё досчитано
      if (_views == widget.totalViews &&
          _shares == widget.totalShares &&
          _conversion == widget.conversionRate) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          color: const Color(0xFF1E1E1E),
          child: Row(
            children: [
              _statColumn('Просмотры', _views.toString(),
                  '+112 с прошлой недели', Colors.green),
              _verticalDivider(),
              _statColumn('Репосты', _shares.toString(),
                  '+53 с прошлой недели', Colors.green),
              _verticalDivider(),
              _statColumn(
                  'Конверсия',
                  '${_conversion.toStringAsFixed(1)}%',
                  '-0.5%',
                  Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statColumn(String title, String value, String sub, Color subColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(color: subColor, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 60,
      color: Colors.grey[700],
    );
  }
}

//второе
class PopularTransitionsCard extends StatefulWidget {
  final List<PopularLinks> popularLinks;
  const PopularTransitionsCard({Key? key, required this.popularLinks})
      : super(key: key);

  @override
  State<PopularTransitionsCard> createState() =>
      _PopularTransitionsCardState();
}

class _PopularTransitionsCardState extends State<PopularTransitionsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final Map<String, int> _animatedClicks = {};

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // снизу
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();

      // Запуск анимации чисел после появления
      Future.delayed(const Duration(milliseconds: 300), () {
        _animateClicks();
      });
    });
  }

  void _animateClicks() {
    final sortedLinks = widget.popularLinks
      ..sort((a, b) => b.clicks.compareTo(a.clicks));
    final topLinks = sortedLinks.take(3).toList();

    for (final link in topLinks) {
      _animatedClicks[link.name] = 0;
    }

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      bool done = true;
      setState(() {
        for (final link in topLinks) {
          final target = link.clicks;
          final current = _animatedClicks[link.name]!;
          if (current < target) {
            done = false;
            _animatedClicks[link.name] =
                (current + (target / 15).ceil()).clamp(0, target);
          }
        }
      });
      if (done) timer.cancel();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconForService(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'telegram':
        return BoxIcons.bxl_telegram;
      case 'linkedin':
        return EvaIcons.linkedin;
      case 'github':
        return Bootstrap.github;
      case 'twitter':
        return BoxIcons.bxl_twitter;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'website':
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedLinks = widget.popularLinks
      ..sort((a, b) => b.clicks.compareTo(a.clicks));
    final topLinks = sortedLinks.take(3).toList();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _sectionCard(
          title: 'Популярные переходы:',
          children: [
            if (topLinks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Нет данных о переходах'),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final link in topLinks) ...[
                    _AnimatedIconStat(
                      icon: _getIconForService(link.name),
                      value: _animatedClicks[link.name] ?? 0,
                    ),
                    if (link != topLinks.last) _verticalDivider(),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

    Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

    Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 60,
      color: Colors.grey[700],
    );
  }
}

class _AnimatedIconStat extends StatefulWidget {
  final IconData icon;
  final int value;

  const _AnimatedIconStat({
    required this.icon,
    required this.value,
  });

  @override
  State<_AnimatedIconStat> createState() => _AnimatedIconStatState();
}

class _AnimatedIconStatState extends State<_AnimatedIconStat>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // bounce при клике
              _scaleController.reverse().then((_) => _scaleController.forward());
            },
            child: Icon(widget.icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text('${widget.value}'),
        ],
      ),
    );
  }
}

//третье
class DeviceUsageCard extends StatefulWidget {
  final int mobile;
  final int desktop;
  final int tablet;

  const DeviceUsageCard({
    Key? key,
    required this.mobile,
    required this.desktop,
    required this.tablet,
  }) : super(key: key);

  @override
  State<DeviceUsageCard> createState() => _DeviceUsageCardState();
}

class _DeviceUsageCardState extends State<DeviceUsageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  double mobilePercent = 0;
  double desktopPercent = 0;
  double tabletPercent = 0;

  int mobileValue = 0;
  int desktopValue = 0;
  int tabletValue = 0;

  @override
  void initState() {
    super.initState();

    final totalViews =
        widget.mobile + widget.desktop + widget.tablet;

    double calcPercent(int value) {
      return totalViews > 0 ? value / totalViews : 0;
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // снизу
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();

      // Запускаем анимацию прогресс-баров
      Future.delayed(const Duration(milliseconds: 300), () {
        _animateProgress(
          calcPercent(widget.mobile),
          calcPercent(widget.desktop),
          calcPercent(widget.tablet),
        );
        _animateNumbers();
      });
    });
  }

  void _animateProgress(double mobile, double desktop, double tablet) {
    const steps = 20;
    int tick = 0;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      tick++;
      setState(() {
        mobilePercent = (mobile * tick / steps).clamp(0, mobile);
        desktopPercent = (desktop * tick / steps).clamp(0, desktop);
        tabletPercent = (tablet * tick / steps).clamp(0, tablet);
      });
      if (tick >= steps) timer.cancel();
    });
  }

  void _animateNumbers() {
    const steps = 20;
    int tick = 0;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      tick++;
      setState(() {
        mobileValue =
            (widget.mobile * tick / steps).round().clamp(0, widget.mobile);
        desktopValue =
            (widget.desktop * tick / steps).round().clamp(0, widget.desktop);
        tabletValue =
            (widget.tablet * tick / steps).round().clamp(0, widget.tablet);
      });
      if (tick >= steps) timer.cancel();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _progressItem(String label, int value, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Text('$value',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            color: Colors.white,
            minHeight: 12,
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            backgroundColor: const Color(0xFF8F8888),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _sectionCard(
          title: 'Устройства:',
          children: [
            _progressItem('Мобильные', mobileValue, mobilePercent),
            _progressItem('Десктоп', desktopValue, desktopPercent),
            _progressItem('Планшеты', tabletValue, tabletPercent),
          ],
        ),
      ),
    );
  }

      Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

//четвертый
class WeeklyViewsCard extends StatefulWidget {
  final List<double> heightFactors; // 7 значений, от 0.0 до 1.0
  final List<String> labels; // 7 подписей для дней

  const WeeklyViewsCard({
    Key? key,
    required this.heightFactors,
    required this.labels,
  }) : super(key: key);

  @override
  State<WeeklyViewsCard> createState() => _WeeklyViewsCardState();
}

class _WeeklyViewsCardState extends State<WeeklyViewsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<double> animatedHeights = [];

  @override
  void initState() {
    super.initState();

    animatedHeights = List.filled(widget.heightFactors.length, 0.0);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // снизу
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      Future.delayed(const Duration(milliseconds: 300), _animateBars);
    });
  }

  void _animateBars() {
    for (int i = 0; i < widget.heightFactors.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        _animateSingleBar(i, widget.heightFactors[i]);
      });
    }
  }

  void _animateSingleBar(int index, double target) {
    const steps = 20;
    int tick = 0;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      tick++;
      setState(() {
        animatedHeights[index] =
            (target * tick / steps).clamp(0, target);
      });
      if (tick >= steps) timer.cancel();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _barStat(String label, double heightFactor) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 20,
              height: 100 * heightFactor,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 24,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _sectionCard(
          title: 'Просмотры за неделю:',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.labels.length, (i) {
                return _barStat(widget.labels[i], animatedHeights[i]);
              }),
            ),
          ],
        ),
      ),
    );
  }

      Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

//класс для отслеживания видимости
class AnimatedVisibilityCard extends StatefulWidget {
  final Widget child;
  final Key visibilityKey;
  final VoidCallback? onAnimationComplete;  // добавляем

  const AnimatedVisibilityCard({
    required this.child,
    required this.visibilityKey,
    this.onAnimationComplete,
    super.key,
  });

  @override
  _AnimatedVisibilityCardState createState() => _AnimatedVisibilityCardState();
}

class _AnimatedVisibilityCardState extends State<AnimatedVisibilityCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_hasAnimated && info.visibleFraction > 0.1) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_animation),
          child: widget.child,
        ),
      ),
    );
  }
}


//пятое
class TrafficSourcesCard extends StatefulWidget {
  final List<_TrafficSource> sources;

  const TrafficSourcesCard({Key? key, required this.sources}) : super(key: key);

  @override
  _TrafficSourcesCardState createState() => _TrafficSourcesCardState();
}

class _TrafficSourcesCardState extends State<TrafficSourcesCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late List<double> _percents;
  late List<int> _values;

  bool _internalAnimationsStarted = false;

  @override
  void initState() {
    super.initState();

    final total = widget.sources.fold<int>(0, (sum, s) => sum + s.value);

    _percents = List.filled(widget.sources.length, 0);
    _values = List.filled(widget.sources.length, 0);

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  Future<void> _playInternalAnimations() async {
    if (_internalAnimationsStarted) return;
    _internalAnimationsStarted = true;

    _controller.forward();

    final total = widget.sources.fold<int>(0, (sum, s) => sum + s.value);

    await Future.delayed(const Duration(milliseconds: 300));
    
    const steps = 20;
    for (int tick = 1; tick <= steps; tick++) {
      await Future.delayed(const Duration(milliseconds: 16));
      setState(() {
        for (int i = 0; i < widget.sources.length; i++) {
          final targetPercent = total > 0 ? widget.sources[i].value / total : 0;
          _percents[i] = ((targetPercent * tick / steps).clamp(0, targetPercent)).toDouble();
          _values[i] = ((widget.sources[i].value * tick / steps).round()).clamp(0, widget.sources[i].value);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _progressItem(String label, int value, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text('$value', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            color: Colors.white,
            minHeight: 12,
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            backgroundColor: const Color(0xFF8F8888),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sources.isEmpty) {
      return _sectionCard(
        title: 'Источники трафика:',
        children: [const Text('Нет данных о трафике')],
      );
    }

    final items = List.generate(widget.sources.length, (index) {
      final s = widget.sources[index];
      return _progressItem(s.label, _values[index], _percents[index]);
    });

    return AnimatedVisibilityCard(
      visibilityKey: const Key('trafficSourcesVisibility'),
      onAnimationComplete: _playInternalAnimations,
      child: _sectionCard(
        title: 'Источники трафика:',
        children: items,
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}


//шестое
class TopActionsCard extends StatefulWidget {
  const TopActionsCard({Key? key}) : super(key: key);

  @override
  _TopActionsCardState createState() => _TopActionsCardState();
}

class _TopActionsCardState extends State<TopActionsCard> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  final int itemCount = 5;
  bool _internalAnimationsStarted = false;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(itemCount, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.easeIn);
    }).toList();
  }

  Future<void> _playInternalAnimations() async {
    if (_internalAnimationsStarted) return;
    _internalAnimationsStarted = true;

    for (var controller in _controllers) {
      await controller.forward();
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildAnimatedItem(Widget child, int index) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _buildAnimatedItem(const _actionItem(Icons.remove_red_eye, 'Просмотры', '78%'), 0),
      _buildAnimatedItem(const Divider(thickness: 1, color: Colors.white, indent: 10, endIndent: 10), 1),
      _buildAnimatedItem(const _actionItem(Bootstrap.person_add, 'Добавление в контакты', '55%'), 2),
      _buildAnimatedItem(const Divider(thickness: 1, color: Colors.white, indent: 10, endIndent: 10), 3),
      _buildAnimatedItem(const _actionItem(OctIcons.share, 'Поделиться', '34%'), 4),
    ];

    return AnimatedVisibilityCard(
      visibilityKey: const Key('topActionsVisibility'),
      onAnimationComplete: _playInternalAnimations,
      child: _sectionCard(
        title: 'Топ действий:',
        children: items,
      ),
    );
  }

    Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

//седьмое
class VisitStatCard extends StatefulWidget {
  final String image;
  final String name;
  final String position;
  final String company;
  final int views;
  final int adds;
  final int shares;

  const VisitStatCard({
    Key? key,
    required this.image,
    required this.name,
    required this.position,
    required this.company,
    required this.views,
    required this.adds,
    required this.shares,
  }) : super(key: key);

  @override
  _VisitStatCardState createState() => _VisitStatCardState();
}

class _VisitStatCardState extends State<VisitStatCard> with TickerProviderStateMixin {
  bool _startCountAnimation = false;

  late AnimationController _viewsController;
  late AnimationController _addsController;
  late AnimationController _sharesController;

  late Animation<int> _viewsAnimation;
  late Animation<int> _addsAnimation;
  late Animation<int> _sharesAnimation;

  @override
  void initState() {
    super.initState();

    _viewsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _addsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _sharesController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _viewsAnimation = IntTween(begin: 0, end: widget.views).animate(CurvedAnimation(parent: _viewsController, curve: Curves.easeOut));
    _addsAnimation = IntTween(begin: 0, end: widget.adds).animate(CurvedAnimation(parent: _addsController, curve: Curves.easeOut));
    _sharesAnimation = IntTween(begin: 0, end: widget.shares).animate(CurvedAnimation(parent: _sharesController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _viewsController.dispose();
    _addsController.dispose();
    _sharesController.dispose();
    super.dispose();
  }

  void _onCardAnimationComplete() {
    setState(() {
      _startCountAnimation = true;
    });

    _viewsController.forward().then((_) {
      _addsController.forward().then((_) {
        _sharesController.forward();
      });
    });
  }

  Widget _sectionCard({required Widget child}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _statItem(IconData icon, Animation<int> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 11),
            Text('${animation.value}', style: const TextStyle(color: Colors.white)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibilityCard(
      visibilityKey: const Key('visitStatCard'),
      onAnimationComplete: _onCardAnimationComplete,
      child: _sectionCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 33,
                // если у тебя есть изображение, можно использовать backgroundImage
                // backgroundImage: NetworkImage(widget.image),
                backgroundColor: Colors.grey.shade700,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(widget.position, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white)),
                  Text(widget.company, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white)),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 60,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  _statItem(Icons.remove_red_eye, _viewsAnimation),
                  const SizedBox(height: 5),
                  _statItem(Bootstrap.person_add, _addsAnimation),
                  const SizedBox(height: 5),
                  _statItem(OctIcons.share, _sharesAnimation),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}










