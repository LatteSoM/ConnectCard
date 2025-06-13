import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class StatScreen extends StatefulWidget{
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const BackButton(color: Colors.purpleAccent,),
              ),
              const Center(
                child: Text(
                  'Аналитика',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
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
    );
  }

  Widget _buildTopStats() {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          _statColumn('Просмотры', '1112', '+112 с прошлой недели', Colors.green),
          _verticalDivider(),
          _statColumn('Репосты', '511', '+53 с прошлой недели', Colors.green),
          _verticalDivider(),
          _statColumn('Конверсия', '2.8%', '-0.5%', Colors.red),
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
    return _sectionCard(
      title: 'Популярные переходы:',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _iconStat(BoxIcons.bxl_telegram, '1112'),
            _verticalDivider(),
            _iconStat(EvaIcons.linkedin, '511'),
            _verticalDivider(),
            _iconStat(Bootstrap.github, '92'),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceUsage() {
    return _sectionCard(
      title: 'Устройства:',
      children: const [
        _progressItem('Мобильные', 1148, 1.0),
        _progressItem('Десктоп', 548, 0.6),
        _progressItem('Планшеты', 144, 0.2),
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
    return _sectionCard(
      title: 'Источники трафика:',
      children: const [
        _progressItem('Прямые переходы', 551, 0.5),
        _progressItem('QR-коды', 782, 0.75),
        _progressItem('Другое', 144, 0.2),
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