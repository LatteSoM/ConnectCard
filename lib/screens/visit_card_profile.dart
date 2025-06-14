import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class VisitCardProfile extends StatefulWidget{
  @override
  State<VisitCardProfile> createState() => _VisitCardProfileState();
}

class _VisitCardProfileState extends State<VisitCardProfile>{
  bool _isEditing = false;
  bool _showQrCode = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = "Барак обама";
    _positionController.text = "Старший кассир";
    _companyController.text = """ООО "KFC" """;
    _aboutController.text = "Просто чиловый парень";
  }

  Future<void> _saveData() async{

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 21),
        child: EditingScope(
          isEditing: _isEditing,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: (){
                      setState(() {
                        if(_isEditing){
                          _saveData();
                          _isEditing = false;
                        }else{
                          _isEditing = true;
                        }
                      });
                    }, icon: _isEditing ? Icon(Bootstrap.check_lg) : Icon(Icons.edit)),
                ],
              ),

                _editableAvatar(),

                SizedBox(height: 16,),

                _editableText(
                  18,
                  controller: _nameController,
                  onEditPressed: () {
                    
                  },),

                // Text("Барак обама", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),

                SizedBox(height: 7,),

                _editableText(
                  14,
                  controller: _positionController,
                  isBold: false,
                  onEditPressed: () {
                    
                  },),

                // Text("Старший кассир", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w200),),

                SizedBox(height: 8,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesome.building, color: Colors.white, size: 24,),
                    SizedBox(width: 5,),
                    // _editableText("""ООО "KFC" """, 14, isBold: false),
                    _editableText(
                      14,
                      isBold: false,
                      controller: _companyController,),
                    // Text("""ООО "KFC" """),
                  ],
                ),

                SizedBox(height: 28,),

                // _editableText("Просто чиловый парень", 14, isBold: false),
                _editableText(
                  14,
                  controller: _aboutController,
                  isBold: false),

                // Text("Просто чиловый парень", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w200),),

                SizedBox(height: 25,),
                if (_showQrCode)...[
                  Text("Связаться со мной", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),

                  SizedBox(height: 16,),

                  InfoCard(
                    icon: Icon(Icons.email_outlined, color: Colors.white, size: 32),
                    title: "Email",
                    subtitle: "obemekfc@mpt.ru",
                    fullWidth: true,
                    ),
                  InfoCard(
                    icon: Icon(Icons.phone, color: Colors.white, size: 32),
                    title: "Телефон",
                    subtitle: "+7 (800) 555 35-35",
                    fullWidth: true,
                    ),
                  InfoCard(
                    icon: Icon(Icons.language, color: Colors.white, size: 32),
                    title: "Сайт",
                    subtitle: "https://goyda.com",
                    fullWidth: true,
                    ),

                  SizedBox(height: 15),

                  Wrap(
                    spacing: 13,
                    runSpacing: 8,
                    children: [
                      InfoCard(
                        icon: Icon(BoxIcons.bxl_telegram, color: Colors.white, size: 24),
                        title: "Телеграм",
                        subtitle: "@InQvd",
                      ),
                      InfoCard(
                        icon: Icon(EvaIcons.linkedin, color: Colors.white, size: 24,),
                        title: "LinkedIn",
                        subtitle: "Профиль Linkedln",
                      ),
                      InfoCard(
                        icon: Icon(Bootstrap.github, color: Colors.white, size: 24),
                        title: "GitHub",
                        subtitle: "Профиль GitHub",
                      ),
                      InfoCard(
                        icon: Icon(Bootstrap.twitter_x, color: Colors.white, size: 24),
                        title: "X",
                        subtitle: "Профиль X",
                      ),
                    ],
                  ),
                ] else ...[
                  Image.asset('assets/icons/telegram-logo.png'),
                ]
              ],
            ),
          )
        ),
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: (){
          setState(() {
            _showQrCode = !_showQrCode;
          });
        },
        fillColor: Color(0xFF784BF7),
        shape: CircleBorder(),
        constraints: BoxConstraints.tight(Size(50,50)),
        child: Icon(IonIcons.qr_code, color: Colors.white,),
      ),
    );
  }


  Widget _editableText(
    double sizeFont, {
    bool isBold = true,
    bool isCentered = true,
    VoidCallback? onEditPressed,
    required TextEditingController controller,
  }) {
    return Row(
      mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _isEditing
            ? IntrinsicWidth(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: sizeFont,
                    color: Colors.white,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w200,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    // border: InputBorder.none,
                  ),
                ),
              )
            : Text(
                controller.text,
                style: TextStyle(
                  fontSize: sizeFont,
                  color: Colors.white,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w200,
                ),
              ),
        if (_isEditing) ...[
          SizedBox(width: 6),
          GestureDetector(
            onTap: onEditPressed,
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ],
    );
  }


  Widget _editableAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage('https://example.com/your-avatar.jpg'), // Заменить на свою
        ),

        if (_isEditing)
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),

        if (_isEditing)
          GestureDetector(
            onTap: () {
              
            },
            child: Icon(
              Icons.photo_camera,
              color: Colors.white,
              size: 28,
            ),
          ),
      ],
    );
  }
}

class EditingScope extends InheritedWidget{
  final bool isEditing;

  const EditingScope({
    super.key,
    required this.isEditing,
    required super.child,
  });

  static EditingScope? of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<EditingScope>();
  }

  @override
  bool updateShouldNotify(EditingScope oldWidget){
    return isEditing != oldWidget.isEditing;
  }
}


class InfoCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool fullWidth;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEditing = EditingScope.of(context)?.isEditing ?? false;
    double cardWidth = fullWidth
        ? double.infinity
        : (MediaQuery.of(context).size.width - 21 * 2 - 13) / 2;

    return Stack(
      children: [
        Container(
          width: cardWidth,
          height: 50,
          margin: EdgeInsets.only(bottom: fullWidth ? 8 : 0),
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFF100E12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Color(0xFF989898),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if(isEditing)Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {

            },
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}

