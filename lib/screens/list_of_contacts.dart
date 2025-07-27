import 'package:connect_card/screens/qr_scan_screen.dart';
import 'package:flutter/material.dart';

class ListOfContacts extends StatefulWidget{
  const ListOfContacts({super.key});

  @override
  State<ListOfContacts> createState() => _ListOfContactsState();

}

class _ListOfContactsState extends State<ListOfContacts> {
  String? selectedFilter; // Для хранения выбранного значения в DropdownButton
  final TextEditingController _searchController = TextEditingController(); // Контроллер для поиска

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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(
                        child: Text(
                          'Ваши Контакты',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.qr_code, color: Colors.white),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanScreen()));
                          },
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
                // Добавляем строку с поиском и фильтром
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Поисковое поле (в 1.5 раза шире)
                      Expanded(
                        flex: 3, // 3 части из 5 (1.5 раза больше чем 2)
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Поиск...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      //Выпадающий список
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            hint: const Text('Ивент', style: TextStyle(color: Colors.white)),
                            dropdownColor: const Color(0xFF1E1B20),
                            icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.5)),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('Первый', style: TextStyle(color: Colors.white))),
                              DropdownMenuItem(value: 'favorites', child: Text('Второй', style: TextStyle(color: Colors.white))),
                              DropdownMenuItem(value: 'recent', child: Text('Третий', style: TextStyle(color: Colors.white))),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedFilter = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Contact(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(radius: 32),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Барак Обама', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Старший кассир', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                Text('ООО KFC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
            SizedBox(width: 24,),
            Container(
              height: 60,
              width: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            SizedBox(width: 5,),
            Expanded(
              flex: 2,
              child: Text(
                'Moscow Python MEETUP 100',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}