import 'dart:convert';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/list_of_visit_card.dart';
import 'package:connect_card/screens/visit_card_profile.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class ShareVisit extends StatefulWidget{
  final String cardId;
  const ShareVisit({super.key, required this.cardId});

  @override
  State<ShareVisit> createState() => _ShareVisitState();
}

class _ShareVisitState extends State<ShareVisit>{
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'];
  String? _token;
  late BusinessCard card;
  Map<String, String> get headers {
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _loadCredentials() async {
    _token = await storage.read(key: 'token');
  }

  Future<void> _initializeData() async{
    await _loadCredentials();
    await _loadCard();
  }


  Future<void> _loadCard() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cards/${widget.cardId}'),
        headers: headers,
        );
      if(!mounted) return; //везде добавить перед setState()
      if(response.statusCode == 200) {
        setState(() {
          card = BusinessCard.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      SnackbarHelper.showMessage(context, 'Ошибка загрузки', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
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
                    child: VisitCard1(
                      fullName: card.fullname,
                      position: card.position ?? '',
                      company: card.company ?? '',
                      socialLinks: card.linkWidgets,
                      isSelected: true,
                      template: VisitCardTemplate.fromString(card.template),
                      contactInfos: card.contactInfos,
                      ),
                  ),
                ),
                const SizedBox(height: 60),
                Center(
                  child: QrImageView(
                        data: '$baseUrl/cards/${widget.cardId}/qr-link',
                        version: QrVersions.auto,
                        size: 240,
                        gapless: false,
                        backgroundColor: Colors.white,
                        embeddedImage: AssetImage('assets/icons/LogoNight.png'),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: Size(48, 28),
                        ),
                      )
                ),
                const SizedBox(height: 80),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ElevatedButton.icon(
                onPressed: () {
                  final uri = Uri.parse('$baseUrl/cards/${widget.cardId}/qr-link');
                  final params = ShareParams(uri: uri);
                  SharePlus.instance.share(params);
                },
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