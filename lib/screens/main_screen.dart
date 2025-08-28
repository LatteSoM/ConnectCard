import 'package:connect_card/screens/list_of_contacts.dart';
import 'package:connect_card/screens/list_of_visit_card.dart';
import 'package:connect_card/screens/profile_screen.dart';
import 'package:connect_card/screens/stat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<TargetFocus> targets = [];

  final GlobalKey keyContacts = GlobalKey();
  final GlobalKey keyVisitCards = GlobalKey();
  final GlobalKey keyProfile = GlobalKey();
  final GlobalKey keyStats = GlobalKey();

  final List<Widget> _screens = [
    ListOfContacts(),
    ListOfVisitCard(),
    ProfileScreen(),
    StatScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 300)); // ждем отрисовки
      _checkAndShowTutorial();
    });
  }

  Future<bool> _isTutorialShown() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('tutorial_shown') ?? false;
}

Future<void> _setTutorialShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('tutorial_shown', true);
}


void _checkAndShowTutorial() async {
  if (!mounted) return;

  bool shown = await _isTutorialShown();
  if (shown) return;

  _initTargets();

  final tutorial = TutorialCoachMark(
    targets: targets,
    colorShadow: Colors.black.withOpacity(0.7),
    textSkip: "Пропустить",
    alignSkip: Alignment(1.0, 0.8),
    paddingFocus: 8,
    onFinish: () async {
      print('Tutorial finished');
      await _setTutorialShown();
    },
    onSkip: () {
      print('Tutorial skipped');
      _setTutorialShown();
      return true;
    },
  )..show(context: context);
}


  void _initTargets() {
    targets = [
      TargetFocus(
        identify: "Contacts",
        keyTarget: keyContacts,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "📒 Здесь список всех твоих контактов",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "VisitCards",
        keyTarget: keyVisitCards,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "💳 Здесь твои визитные карточки",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Profile",
        keyTarget: keyProfile,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "👤 Здесь находится твой профиль",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Stats",
        keyTarget: keyStats,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "📊 Здесь можно посмотреть аналитику визитки",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: const Color.fromARGB(255, 255, 9, 9).withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              gap: 8,
              activeColor: Colors.purpleAccent,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              duration: Duration(milliseconds: 400),
              color: Colors.white,
              tabs: [
                GButton(
                  key: keyContacts,
                  icon: Bootstrap.person_arms_up,
                  text: 'Контакты',
                ),
                GButton(
                  key: keyVisitCards,
                  icon: Bootstrap.person_vcard,
                  text: 'Визитки',
                ),
                GButton(
                  key: keyProfile,
                  icon: OctIcons.home,
                  text: 'Профиль',
                ),
                GButton(
                  key: keyStats,
                  icon: FontAwesome.chart_line_solid,
                  text: 'Аналитика',
                ),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavyBar(
      //   backgroundColor: Colors.black,
      //   selectedIndex: _currentIndex,
      //   showElevation: true,
      //   itemCornerRadius: 24,
      //   containerHeight: 50,
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   onItemSelected: (index) => setState(() => _currentIndex = index),
      //   items: [
      //     _buildNavyBarItem(Icons.home, 'Главная', keyContacts),
      //     _buildNavyBarItem(Bootstrap.card_heading, 'Визитки', keyVisitCards),
      //     _buildNavyBarItem(Icons.person, 'Профиль', keyProfile),
      //     _buildNavyBarItem(Icons.analytics, 'Аналитика', keyStats),
      //   ],
      // ),
    );
  }

  // BottomNavyBarItem _buildNavyBarItem(IconData icon, String title, Key key) {
  //   return BottomNavyBarItem(
  //     icon: Container(
  //       key: key,
  //       child: Icon(icon),
  //     ),
  //     title: Text(title),
  //     activeColor: Colors.white,
  //     inactiveColor: Colors.grey,
  //     textAlign: TextAlign.center,
  //   );
  // }
}

