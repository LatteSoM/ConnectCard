import 'dart:convert';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;

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
  bool _isAnalyticEmpty = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeData();
  // }

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
                        _buildTopStats(),
                        const SizedBox(height: 16),
                        _buildPopularTransitions(),
                        const SizedBox(height: 16),
                        _buildDeviceUsage(),
                        const SizedBox(height: 16),
                        _buildWeeklyViews(),
                        const SizedBox(height: 16),
                        _buildTrafficSources(),
                        const SizedBox(height: 16),
                        _buildTopActions(),
                        const SizedBox(height: 16),
                        _buildVisitStat(),
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

    // Сначала сортируем, потом берем топ-3
    trafficSources.sort((a, b) => b.value.compareTo(a.value));
    final topSources = trafficSources.take(3).toList();

    final total = topSources.fold(0, (sum, source) => sum + source.value);

    return _sectionCard(
      title: 'Источники трафика:',
      children: [
        if (topSources.isEmpty)
          const Text('Нет данных о трафике')
        else
          ...topSources.map((source) => _progressItem(
                source.label,
                source.value,
                total > 0 ? source.value / total : 0,
              )),
      ],
    );
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

  Widget _buildVisitStat(){
    return _sectionCard(
      title: 'Статистика по визитке',
      children: [
        _visitItem("image", "Барак Обама", 'Старший кассир', 'ООО KFC', 551, 782, 144)
      ]);
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

class _visitItem extends StatelessWidget{
  final String image;
  final String name;
  final String position;
  final String company;
  final int views;
  final int adds;
  final int shares;

  const _visitItem(this.image, this.name, this.position, this.company, this.views, this.adds, this.shares);

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 33,
          ),
          const SizedBox(width: 16,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
              Text(position, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),),
              Text(company, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),),
            ],
          ),
          const SizedBox(width: 16,),
          Container(
            width: 1,
            height: 60,
            color: Colors.white,
          ),
          const SizedBox(width: 16,),
          Column(
            children: [
              _statItem(Icons.remove_red_eye, views),
              const SizedBox(height: 5,),
              _statItem(Bootstrap.person_add, adds),
              const SizedBox(height: 5,),
              _statItem(OctIcons.share, shares),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, int value){
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20,),
        const SizedBox(width: 11,),
        Text('$value'),
      ],
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