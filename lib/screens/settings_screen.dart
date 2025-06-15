import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SettingsScreen extends StatefulWidget{
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{
  bool _notificationsEnabled = true;
  String _selectedTheme = 'Системная';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const BackButton(color: Colors.purpleAccent),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(onPressed: (){

                    },
                    icon: Icon(Icons.check)),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                'Настройки',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Divider(
              color: Colors.white,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.language, color: Colors.white, size: 32,),
                  SizedBox(width: 26),
                  Text(
                    'Язык',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(width: 26),
                  Expanded(
                    child: LanguageDropdown(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.white, size: 32,),
                  SizedBox(width: 12),
                  Text(
                    'Уведомления',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Spacer(),
                  NotificationToggle(
                    value: _notificationsEnabled,
                    onChanged: (bool val){
                      setState(() {
                        _notificationsEnabled = val;
                      });
                    }
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.brightness_6, color: Colors.white, size: 32,),
                  SizedBox(width: 26,),
                  Text(
                    'Тема',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(width: 26,),
                  Expanded(
                    child: ThemeSelector(
                      selectedTheme: _selectedTheme,
                      onThemeChanged: (String theme){
                        setState(() {
                          _selectedTheme = theme;
                        });
                      }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: Icon(OctIcons.question, color: Colors.white),
                  label: Text('ConnectCard FAQ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ),
            ),                   
          ],
        ),
      ),
    );
  }
}

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({Key? key}) : super(key: key);

  @override
  _LanguageDropdownState createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String _selectedLanguage = 'Русский';

  final List<String> _languages = [
    'Русский',
    'English',
    'Español',
    'Deutsch',
    'Français',
    '中文',
    '日本語',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFF1B1A20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2A272F)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          dropdownColor: Color(0xFF1B1A20),
          iconEnabledColor: Colors.grey[400],
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            height: 1.0,
          ),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLanguage = newValue!;
            });
          },
          items: _languages.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NotificationToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationToggle({Key? key, required this.value, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      activeColor: Color(0xFF7C4DFF),
      inactiveThumbColor: Colors.grey[700],
      inactiveTrackColor: Colors.grey[800],
      onChanged: onChanged,
    );
  }
}

class ThemeSelector extends StatelessWidget {
  final String selectedTheme;
  final ValueChanged<String> onThemeChanged;

  const ThemeSelector({Key? key, required this.selectedTheme, required this.onThemeChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = ['Системная', 'Светлая', 'Темная'];

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xFF1B1A20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2A272F)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((option) {
          final bool isSelected = option == selectedTheme;
          return Expanded(
            child: GestureDetector(
              onTap: () => onThemeChanged(option),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF7C4DFF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
