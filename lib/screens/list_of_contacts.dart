import 'dart:convert';

import 'package:connect_card/models/user_model.dart';
import 'package:connect_card/screens/friend_card_profile.dart';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';

class ListOfContacts extends StatefulWidget{
  const ListOfContacts({super.key});

  @override
  State<ListOfContacts> createState() => _ListOfContactsState();

}

class _ListOfContactsState extends State<ListOfContacts> {
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

  List<Contact> contacts = [];
  bool _isLoading = true;
  bool _isContactsEmpty = false;
  String? selectedContactId;

  String? selectedFilter; // Для хранения выбранного значения в DropdownButton
  final TextEditingController _searchController = TextEditingController(); // Контроллер для поиска


  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadCredentials();
    await _loadContacts();
  }

  Future<void> _loadCredentials() async {
    _id = await storage.read(key: 'id');
    _token = await storage.read(key: 'token');
  }

  Future<void> _loadContacts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/contacts/user/$_id'),
      headers: headers,
    );

    if(response.statusCode == 200){
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      if(jsonData.isEmpty){
        setState(() {
          _isLoading = false;
          _isContactsEmpty = true;
        });
      }else{
        setState(() {
          contacts = jsonData.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
          _isLoading = false;
        });        
      }
    }else{
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка', isSuccess: false);
    }
  }

  Future<void> _deleteContact(String contact_id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/contacts/$contact_id'),
      headers: headers
    );
    if(response.statusCode == 200){
      SnackbarHelper.showMessage(context, 'Контакт успешно удален');
      _loadContacts();
    }else{
      SnackbarHelper.showMessage(context, 'Извините, произошла ошибка при удалении', isSuccess: false);
    }
  }

  void _showContactContextMenu(BuildContext context, Offset position, String index) async {
    setState(() {
      selectedContactId = index;
    });

    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, 0),
      items: [
        PopupMenuItem(
          value: 'share',
          child: ListTile(
            leading: Icon(Bootstrap.share_fill),
            title: Text('Поделиться?'),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Удалить'),
          ),
        ),
      ],
    );

    setState(() {
      selectedContactId = null;
    });

    if (selected == 'share') {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ShareVisit(cardId: index,)));
    } else if (selected == 'delete') {
      _deleteContact(index);
      // _deleteCard(index);
    }
  }

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
                          icon: const Icon(Bootstrap.person_bounding_box, color: Colors.white),
                          onPressed: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanScreen()));
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FriendCardProfile()));
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
              ],
            ),
          ),
          if(_isContactsEmpty)
            Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Добавь нового контакта',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(text: 'Нажми на кнопку '),
                                WidgetSpan(
                                  child: Icon(Icons.qr_code, size: 16, color: Colors.white.withOpacity(0.7))),
                                const TextSpan(text: ' выше'),
                              ],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ),
            if(!_isContactsEmpty) ...[
              SizedBox(height: 20,),
              _isLoading
              ? CircularProgressIndicator()
              : Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12) + const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
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
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              final contact = contacts[index];
                              final isSelected = selectedContactId == contact.id;
                              return Padding(
                                padding: EdgeInsets.only(bottom: 14),
                                child: GestureDetector(
                                  onLongPressStart: (details) {
                                    _showContactContextMenu(context, details.globalPosition, contact.id);
                                  },
                                  child: Opacity(
                                    opacity: selectedContactId == null || isSelected ? 1.0 : 0.5,
                                    child: ContactCard(
                                      fullName: contact.card?.fullname ?? '',
                                      position: contact.card?.position ?? '',
                                      company: contact.card?.company ?? '',
                                      avatarURL: contact.user.avatar ?? '',
                                      event: contact.event,
                                      isSelected: isSelected,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (selectedContactId != null)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedContactId = null;
                                });
                              },
                              child: Container(color: Colors.transparent),
                            )
                          )
                        ],
                      )
                    ),
                  ],
                ),
              )
            ],
        ],
      ),
    );
  }
}

class ContactCard extends StatefulWidget{
  final String fullName;
  final String position;
  final String company;
  final String avatarURL;
  final Event? event;
  final bool isSelected;

  const ContactCard({
    Key? key,
    required this.fullName,
    required this.position,
    required this.company,
    required this.avatarURL,
    this.event,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isEventExpanded = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    
    _glowAnimation = Tween(begin: 0.05, end: 0.2).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.isSelected) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ContactCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }
    @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(_glowAnimation.value * 2),
                width: widget.isSelected ? 3 : 2,
              ),
              boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(_glowAnimation.value),
                      blurRadius: 10 + _glowAnimation.value * 20,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
            ),
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Основная строка с информацией
                Row(
                  children: [
                    CircleAvatar(radius: 32),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.fullName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(widget.position, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                        Text(widget.company, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    SizedBox(width: 24),
                    Container(
                      height: 60,
                      width: 1,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () {
                          if (widget.event != null) {
                            setState(() => _isEventExpanded = !_isEventExpanded);
                          }
                        },
                        child: Text(
                          widget.event?.name ?? 'Не указано',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            decoration: widget.event != null 
                              ? TextDecoration.underline 
                              : TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Развернутая информация о митапе
                if (_isEventExpanded && widget.event != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        Divider(color: Colors.white.withOpacity(0.2)),
                        SizedBox(height: 8),
                        _buildEventDetailRow(Icons.calendar_today, widget.event!.formattedDate),
                        SizedBox(height: 8),
                        _buildEventDetailRow(Icons.location_on, widget.event!.place),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Вспомогательный метод для отображения строки с иконкой
  Widget _buildEventDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}