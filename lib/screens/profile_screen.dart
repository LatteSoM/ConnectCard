import 'package:connect_card/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget{
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{
  String? formattedPhone;

  @override
  void initState(){
    super.initState();
    formattedPhone = formatRussianPhone();
  }

  String formatRussianPhone() {
    String phone = widget.user.phoneNumber!;
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (!cleaned.startsWith('+7') || cleaned.length != 12) {
      return phone;
    }

    final countryCode = '+7';
    final areaCode = cleaned.substring(2, 5); 
    final part1 = cleaned.substring(5, 8);
    final part2 = cleaned.substring(8, 10);
    final part3 = cleaned.substring(10, 12);

    return '$countryCode ($areaCode) $part1-$part2-$part3';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('http://127.0.0.1:8001${widget.user.avatarUrl}'),
                backgroundColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "${widget.user.firstName}",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent.shade100,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "@username",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.deepPurpleAccent),
            const SizedBox(height: 20),
            // Добавим условно еще пару строк для примера (например, контакты)
            Row(
              children: const [
                Icon(Icons.email, color: Colors.deepPurpleAccent),
                SizedBox(width: 12),
                Text(
                  "user@example.com",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.deepPurpleAccent),
                SizedBox(width: 12),
                Text(
                  formattedPhone ?? 'Загрузка...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}