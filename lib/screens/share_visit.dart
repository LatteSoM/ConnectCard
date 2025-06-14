import 'package:connect_card/screens/list_of_visit_card.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class ShareVisit extends StatefulWidget{
  const ShareVisit({super.key});

  @override
  State<ShareVisit> createState() => _ShareVisitState();
}

class _ShareVisitState extends State<ShareVisit>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141218),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const BackButton(color: Colors.purpleAccent),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: VisitCard(),
                  ),
                ),
                const SizedBox(height: 100),
                Center(
                  child: Image.asset(
                    'assets/icons/qr_code.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(OctIcons.share, color: Colors.white),
                label: Text('Поделиться ссылкой на визитку', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ),
          ],
        ),
      ),
    );
  }
}