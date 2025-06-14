import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class ListOfVisitCard extends StatefulWidget{
  const ListOfVisitCard({super.key});

  @override
  State<ListOfVisitCard> createState() => _ListOfVisitCardState();
}

class _ListOfVisitCardState extends State<ListOfVisitCard> {
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.purpleAccent.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.purpleAccent),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const Text(
                        'Ваши Визитки',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 25),
                  child: VisitCard(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class VisitCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1B1A20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(radius: 48),
                  ),
                  SizedBox(height: 15),
                  _socialLink(Bootstrap.twitter_x, 'https://x.com/'),
                  _socialLink(Bootstrap.telegram, '@trueKazakh'),
                  _socialLink(Bootstrap.instagram, '@kaZanOVa'),
                ],
              ),
            ),
            SizedBox(width: 30,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: const [
                      Text('Барак Обама', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Старший Кассир', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
                      Text('ООО KFC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Image.asset('assets/icons/qr_code.png', height: 69),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialLink(IconData icon, String link) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          Icon(icon, size: 14),
          SizedBox(width: 5),
          Text(link, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }
}