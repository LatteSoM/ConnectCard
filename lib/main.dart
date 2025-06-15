import 'package:connect_card/screens/list_of_visit_card.dart';
import 'package:connect_card/screens/login_screen.dart';
import 'package:connect_card/screens/profile_screen.dart';
import 'package:connect_card/screens/settings_screen.dart';
import 'package:connect_card/screens/share_visit.dart';
import 'package:connect_card/screens/stat_screen.dart';
import 'package:connect_card/screens/visit_card_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async{
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsScreen(),
      theme: ThemeData.dark(),
    );
  }
}
