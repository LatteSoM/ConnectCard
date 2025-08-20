import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connect_card/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:connect_card/third_party/matrix_gesture_detector.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class VisitCardDesigner extends StatefulWidget {
  const VisitCardDesigner({super.key});

  @override
  State<VisitCardDesigner> createState() => _VisitCardDesignerState();
}

enum ElementType { text, shape, image, background }
enum ShapeType { square, circle, triangle }
const Map<ShapeType, String> shapeLabels = {
  ShapeType.square: "Квадрат",
  ShapeType.circle: "Круг",
  ShapeType.triangle: "Треугольник",
};
class _VisitCardDesignerState extends State<VisitCardDesigner> {
  
  final TextEditingController _controller1 = TextEditingController();
  final baseUrl = dotenv.env['BASE_URL'];
  final storage = FlutterSecureStorage();

  List<EditableElement> elements = [
      EditableElement(
    type: ElementType.shape,
    matrix: Matrix4.identity()..translate(-118.66667175292969, -33.66667175292969),
    shapeType: ShapeType.circle,
    color: Colors.red,
    width: 100,
    height: 100,
  ),
  EditableElement(
    type: ElementType.text,
    matrix: Matrix4.identity()..translate(-19.0, -51.0),
    text: "Name",
    fontSize: 18,
    baseFontSize: 18,
    textColor: Colors.white,
  ),
  EditableElement(
    type: ElementType.text,
    matrix: Matrix4.identity()..translate(-18.333328247070312, 3.6666717529296875),
    text: "Info",
    fontSize: 18,
    baseFontSize: 18,
    textColor: Colors.white,
  ),
];


  bool lockAspectRatio = false;
  int? selectedIndex;
  ElementType? selectedElementType;
  double fontSize = 18;
  double rotationAngle = 0;
  double width = 100;
  double height = 50;
  Color textColor = Colors.white;
  String fontFamily = 'Roboto';
  FontWeight fontWeight = FontWeight.normal;
  ShapeType shapeType = ShapeType.square;
  Color shapeColor = Colors.blue;

  Future<void> _saveCard() async {
    final token = await storage.read(key: 'token');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = {
      "fullname": "AlexTest",
      "elements": elements.map((e) => e.toJson()).toList(),
    };

    for(var item in elements) {
      print(item.color);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/cards/'),
      headers: headers,
      body: jsonEncode(body),
    );

    if(response.statusCode == 200) {
      SnackbarHelper.showMessage(context, 'Успешно');
    } else {
      SnackbarHelper.showMessage(context, 'Ошибка', isSuccess: false);
    }
  }

  String _getCreateButtonText() {
    switch (selectedElementType) {
      case ElementType.text:
        return 'Добавить текст';
      case ElementType.shape:
        return 'Добавить фигуру';
      case ElementType.image:
        return 'Добавить изображение';
      case ElementType.background:
        return 'Изменить задний фон';
      default:
        return 'Выберите элемент';
    }
  }

  void _handleCreateButtonPress() {
    switch (selectedElementType) {
      case ElementType.text:
        setState(() {
          elements.add(
            EditableElement(
              type: ElementType.text,
              matrix: Matrix4.identity(),
              text: "Example",
              fontSize: 18,
              baseFontSize: 18,
              textColor: Colors.white,
            ),
          );
        });
        break;
      case ElementType.shape:
        print('Добавляем фигуру');
        setState(() {
          elements.add(
            EditableElement(
              type: ElementType.shape,
              matrix: Matrix4.identity(),
              shapeType: ShapeType.circle,
              color: Colors.red,
              width: 100,
              height: 100,
            ),
          );
        });
        break;
      case ElementType.image:
  print('Добавляем изображение');
  _pickImage().then((selectedImage) {
    if (selectedImage != null) {
      setState(() {
        elements.add(
          EditableElement(
            type: ElementType.image,
            matrix: Matrix4.identity(),
            imageProvider: FileImage(selectedImage),
          ),
        );
      });
    } else {
      print("Изображение не выбрано");
    }
  });
  break;

      default:
        print('Элемент не выбран');
    }
  }

  Future<File?> _pickImage() async {
    // if(await Permission.photos.request().isGranted) {
    //   final picker = ImagePicker();
    //   final pickedFile = await picker.pickImage(
    //     source: ImageSource.gallery,
    //   );

    //   if(pickedFile != null) {
    //     setState(() {
    //       _selectedImage = File(pickedFile.path);
    //     });
    //   }
    // }else {
    //   SnackbarHelper.showMessage(context, 'Необходимо разрешение для доступа к галерее', isSuccess: false);
    // }
    final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if(pickedFile != null) {
        return File(pickedFile.path);
      }
    return null;
  }

  void _removeElement() {
    if(selectedIndex != null) {
      setState(() {
        elements.removeAt(selectedIndex!);
        selectedIndex = null;
      });
    }
  }

  void _moveLayerUp() {
    if(selectedIndex != null && selectedIndex! < elements.length - 1) {
      setState(() {
        final temp = elements[selectedIndex! + 1];
        elements[selectedIndex! + 1] = elements[selectedIndex!];
        elements[selectedIndex!] = temp;
        selectedIndex = selectedIndex!+1;
      });
    }
  }

  void _moveLayerDown() {
    if(selectedIndex != null && selectedIndex! > 0) {
      setState(() {
        final temp = elements[selectedIndex! - 1];
        elements[selectedIndex! - 1] = elements[selectedIndex!];
        elements[selectedIndex!] = temp;
        selectedIndex = selectedIndex!-1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141218),
      body: Column(
        children: [
          // Шапка (кнопки Назад, тайтл и сохранить)
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
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.purpleAccent),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            onPressed: () => _saveCard(),
                          ),
                        ],
                      ),
                      const Text(
                        'Конструктор визитки',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white, thickness: 1, height: 0),
              ],
            ),
          ),

          // Кнопки (Выбор элементов)
          SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: EdgeInsets.zero,
  child: Row(
    children: List.generate(elements.length, (index) {
      final item = elements[index];

      // Заголовок
      String label;
      IconData icon;
      if (item.type == ElementType.text) {
        label = item.text ?? "Текст";
        icon = Icons.text_fields;
      } else if (item.type == ElementType.shape) {
        label = shapeLabels[item.shapeType] ?? item.shapeType.toString();
        switch (item.shapeType) {
          case ShapeType.circle:
            icon = Icons.circle;
            break;
          case ShapeType.square:
            icon = Icons.crop_square;
            break;
          case ShapeType.triangle:
            icon = Icons.change_history;
            break;
          default:
            icon = Icons.crop_square;
        }
      } else if (item.type == ElementType.image) {
        label = 'Изображение';
        icon = Icons.photo;
      } else {
        label = "Элемент";
        icon = Icons.extension;
      }

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
            selectedElementType = elements[index].type;
            if(elements[index].type == ElementType.text) {
              _controller1.text = elements[index].text ?? '';
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selectedIndex == index 
                ? Colors.purple.withOpacity(0.3)
                : const Color(0xFF141218),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedIndex == index 
                  ? Colors.purpleAccent 
                  : Colors.grey[700]!,
              width: selectedIndex == index ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: selectedIndex == index 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }),
  ),
),

          const SizedBox(height: 20),

          // Поле визитки
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              //Нужен для того, чтобы когда кликаем по пустой области в визитке то выделение снималось
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    selectedIndex = null;
                  });
                },
                //Цвет визитки
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blueAccent, Colors.purpleAccent],
                          ),
                        ),
                      ),
                    ),
                    ...List.generate(elements.length, (i) => buildEditableElement(elements[i], i)),
                  ],
                ),
              )
            ),
          ),
          if(selectedIndex != null)
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: () {
                  _removeElement();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: EdgeInsets.zero,
                  minimumSize: Size(45, 45),
                  fixedSize: Size(45, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('-', style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ),

          //Блок настроек
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: selectedIndex != null
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (selectedIndex != null && selectedElementType == ElementType.text) ...[
                                // Настройки для текста
                                _buildLayerButtons(),
                                _buildTextFieldWithFontWeight(),
                                _buildFontFamilyWithColorPicker(),
                                _buildFontSizeSlider(),
                                _buildRotationSlider(),
                              ] else if (selectedIndex != null && selectedElementType == ElementType.shape) ...[
                                _buildLayerButtons(),
                                _buildShapeHeightSlider(),
                                _buildLockButton(),
                                _buildShapeWidthSlider(),
                                _buildShapeDropdownWithColorPicker(),
                                _buildRotationSlider(),
                              ] else if (selectedIndex != null && selectedElementType == ElementType.image) ...[
                                _buildLayerButtons(),
                                _buildShapeHeightSlider(),
                                _buildLockButton(),
                                _buildShapeWidthSlider(),
                                _buildOpacitySlider(),
                                _buildRotationSlider(),
                              ],
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: TextButton(
                          onPressed: () => _handleCreateButtonPress(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _getCreateButtonText(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ),

          // Нижняя панель выбора элементов
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomBarItem(Icons.text_fields, 'Текст', ElementType.text),
                    _buildBottomBarItem(Icons.crop_square, 'Фигура', ElementType.shape),
                    _buildBottomBarItem(Icons.image, 'Изображение', ElementType.image),
                    _buildBottomBarItem(Icons.format_paint, 'Фон', ElementType.background),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildEditableElement(EditableElement item, int index) {
  return MatrixGestureDetector(
    shouldTranslate: true,
    shouldScale: true,
    shouldRotate: true,
    onMatrixUpdate: (newMatrix, _, __, ___) {
      setState(() {
        item.matrix = newMatrix;

        // Масштаб
        final scaleX = sqrt(pow(newMatrix.storage[0], 2) + pow(newMatrix.storage[1], 2));
        item.scaleFactor = scaleX;

        if (item.type == ElementType.text) {
          item.fontSize = (item.baseFontSize ?? 18) * item.scaleFactor;
        } else {
          item.width = (item.baseWidth ?? 100) * item.scaleFactor;
          item.height = (item.baseHeight ?? 100) * item.scaleFactor;
        }
      });
    },
    onScaleStart: () {
      setState(() {
        selectedIndex = index;
        selectedElementType = item.type;
      });
    },
    onScaleEnd: () {  },
    child: OverflowBox(
      minWidth: 0,
      minHeight: 0,
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..multiply(item.matrix)
          ..rotateZ(item.rotationAngle * pi / 180),
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
              selectedElementType = item.type;
              if (item.type == ElementType.text) {
                _controller1.text = item.text ?? '';
              }
            });
          },
          child: _buildElementWidget(item, index),
        ),
      ),
    ),
  );
}

Widget _buildElementWidget(EditableElement item, int index) {
  if (item.type == ElementType.text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: selectedIndex == index && selectedElementType == ElementType.text
            ? Border.all(color: Colors.yellow, width: 2)
            : null,
      ),
      child: Text(
        item.text ?? '',
        style: TextStyle(
          color: item.textColor,
          fontSize: item.fontSize,
          fontWeight: item.fontWeight ?? FontWeight.normal,
          fontFamily: item.fontFamily ?? 'Roboto',
        ),
      ),
    );
  } else if (item.type == ElementType.shape) {
    return Container(
      width: item.width,
      height: item.height,
      decoration: BoxDecoration(
        border: selectedIndex == index && selectedElementType == ElementType.shape
            ? Border.all(color: Colors.yellow, width: 2)
            : null,
      ),
      child: CustomPaint(
        size: Size(item.width, item.height),
        painter: ShapePainter(
          shapeType: item.shapeType!,
          color: item.color,
        ),
      ),
    );
  } else if (item.type == ElementType.image) {
    return Opacity(
      opacity: item.imageOpacity,
      child: Container(
        width: item.width,
        height: item.height,
        decoration: BoxDecoration(
          border: selectedIndex == index && selectedElementType == ElementType.image
              ? Border.all(color: Colors.yellow, width: 2)
              : null,
          image: DecorationImage(
            image: item.imageProvider!,
            fit: BoxFit.cover,
          )
        ),

      ),
    );
  }
  return const SizedBox.shrink();
}

Widget _buildOpacitySlider() {
  final item = elements[selectedIndex!];
  return _buildCustomSlider(
    'Прозрачность',
    item.imageOpacity,
    0.1,
    1.0,
    (value) {
      setState(() {
        item.imageOpacity = value;
      });
    },
  );
}



  Widget _buildLockButton() {
    return IconButton(
      icon: Icon(
        lockAspectRatio ? Icons.lock : Icons.lock_open,
        color: Colors.white,
        size: 24,
      ),
      onPressed: () {
        setState(() {
          lockAspectRatio = !lockAspectRatio;
        });
      },
    );
  }




  Widget _buildBottomBarItem(IconData icon, String label, ElementType type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedElementType = type;
          selectedIndex = null;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selectedElementType == type ? Colors.purpleAccent : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: selectedElementType == type ? Colors.purpleAccent : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

//Виджет Текст и Начертание
  Widget _buildTextFieldWithFontWeight() {
    const inputHeight = 56.0;
    const inputPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 16);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: inputHeight,
              child: TextField(
                controller: _controller1,
                decoration: InputDecoration(
                  labelText: 'Текст',
                  labelStyle: const TextStyle(color: Colors.white),
                  contentPadding: inputPadding,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  if (selectedIndex != null) {
                    setState(() => elements[selectedIndex!].text = value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: inputHeight,
              child: DropdownButtonFormField<FontWeight>(
                decoration: InputDecoration(
                  labelText: 'Начертание',
                  labelStyle: const TextStyle(color: Colors.white),
                  contentPadding: inputPadding,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                dropdownColor: Colors.grey[800],
                value: elements[selectedIndex!].fontWeight,
                items: const [
                  DropdownMenuItem(
                    value: FontWeight.normal,
                    child: Text('Обычный', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                    value: FontWeight.bold,
                    child: Text('Жирный', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                    value: FontWeight.w300,
                    child: Text('Легкий', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) {
                  if (value != null && selectedIndex != null) {
                    setState(() => elements[selectedIndex!].fontWeight = value);
                  }
                },
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

//Виджет Шрифт и Цвет
  Widget _buildFontFamilyWithColorPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Шрифт',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                dropdownColor: Colors.grey[800],
                value: elements[selectedIndex!].fontFamily,
                items: ['Roboto', 'Arial', 'Times New Roman', 'Courier New']
                    .map((font) => DropdownMenuItem(
                          value: font,
                          child: Text(
                            font,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null && selectedIndex != null) {
                    setState(() => elements[selectedIndex!].fontFamily = value);
                  }
                },
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 56,
              child: InkWell(
                onTap: () async {
                  final color = await showDialog<Color>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Выберите цвет'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          paletteType: PaletteType.hueWheel,
                          pickerColor: elements[selectedIndex!].textColor,
                          onColorChanged: (color) {
                            if(selectedIndex != null) {
                              setState(() {
                                elements[selectedIndex!].textColor = color;
                              });
                            }
                          }),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, textColor),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  if (color != null) {
                    setState(() => textColor = color);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey[800],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: elements[selectedIndex!].textColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Цвет текста',
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//Виджет Форма и Цвет
  Widget _buildShapeDropdownWithColorPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: DropdownButtonFormField<ShapeType>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Форма',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              dropdownColor: Colors.grey[800],
              value: elements[selectedIndex!].shapeType,
              items: ShapeType.values.map((shape) {
                return DropdownMenuItem(
                  value: shape,
                  child: Text(
                    shapeLabels[shape]!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && selectedIndex != null) {
                  setState(() {
                    elements[selectedIndex!].shapeType = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            fit: FlexFit.tight,
            child: InkWell(
              onTap: () async {
                final color = await showDialog<Color>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Выберите цвет'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                          paletteType: PaletteType.hueWheel,
                          pickerColor: elements[selectedIndex!].color,
                          onColorChanged: (color) {
                            if(selectedIndex != null) {
                              setState(() {
                                elements[selectedIndex!].color = color;
                              });
                            }
                          }),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, shapeColor),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                if (color != null) {
                  setState(() => shapeColor = color);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[800],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: elements[selectedIndex!].color,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Цвет фигуры',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerButtons() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _moveLayerUp(),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.grey[900],
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'На передний план',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _moveLayerDown(),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.grey[900],
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'На задний план',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
}





//Виджет пользовательского слайдера
  Widget _buildCustomSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
  final TextEditingController controller = TextEditingController(text: value.toStringAsFixed(1));

  int? divisions;
  final diff = max - min;
  if (diff >= 1) {
    divisions = diff.toInt();
  } else {
    divisions = null;
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (text) {
                  final newValue = double.tryParse(text) ?? value;
                  final clampedValue = newValue.clamp(min, max).toDouble();
                  controller.text = clampedValue.toStringAsFixed(1);
                  onChanged(clampedValue);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: const Color(0xFF8F8888),
            trackHeight: 12,
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            onChanged: (newValue) {
              controller.text = newValue.toStringAsFixed(1);
              onChanged(newValue);
            },
          ),
        ),
      ],
    ),
  );
}


//Виджет для создания SlideBar для размера шрифта
Widget _buildFontSizeSlider() {
  final item = elements[selectedIndex!];
  return _buildCustomSlider(
    'Размер шрифта',
    item.fontSize!,
    8,
    36,
    (value) {
      setState(() {
        // Пересчёт базового размера так, чтобы масштаб в жестах сохранился
        item.baseFontSize = value / item.scaleFactor;
        item.fontSize = value;
      });
    },
  );
}

Widget _buildShapeWidthSlider() {
  final item = elements[selectedIndex!];
  return _buildCustomSlider(
    'Ширина',
    item.width,
    20,
    500,
    (value) {
      setState(() {
        item.baseWidth = value/item.scaleFactor;
        item.width = value;

        if(lockAspectRatio) {
          item.baseHeight = value/item.scaleFactor;
          item.height = value;
        }
      });
    },
  );
}

Widget _buildShapeHeightSlider() {
  final item = elements[selectedIndex!];
  return _buildCustomSlider(
    'Высота',
    item.height,
    20,
    500,
    (value) {
      setState(() {
        item.baseHeight = value/item.scaleFactor;
        item.height = value;

        if(lockAspectRatio) {
          item.baseWidth = value/item.scaleFactor;
          item.width = value;
        }
      });
    },
  );
}


//Виджет для создания SlideBar для ротации объекта
  Widget _buildRotationSlider() {
    return _buildCustomSlider(
      'Поворот (°)', 
      elements[selectedIndex!].rotationAngle, 
      -180, 
      180, 
      (value) {
        setState(() => elements[selectedIndex!].rotationAngle = value);
      },
    );
  }

  void _saveDesign() {
    debugPrint('Сохранение позиций:');
    for (var item in elements) {
      debugPrint('${item.text}: ${item.matrix}');
    }
  }
}


class EditableElement {
  ElementType type;

  // Общие свойства
  Matrix4 matrix;
  double rotationAngle;
  double scaleFactor;
  double width;
  double height;
  Color color;

  // Для текста
  String? text;
  double? fontSize;
  double? baseFontSize;
  String fontFamily;
  FontWeight fontWeight;
  Color textColor;

  // Для фигур
  ShapeType? shapeType;
  double? baseWidth;
  double? baseHeight;

  //Для изображений
  ImageProvider? imageProvider;
  double imageOpacity;

  EditableElement({
    required this.type,
    required this.matrix,
    this.rotationAngle = 0,
    this.scaleFactor = 1.0,
    this.width = 100,
    this.height = 100,
    this.color = Colors.white,

    // текстовые
    this.text,
    this.fontSize,
    this.baseFontSize,
    this.fontFamily = 'Roboto',
    this.fontWeight = FontWeight.normal,
    this.textColor = Colors.white,

    // фигуры
    this.shapeType,
    this.baseWidth,
    this.baseHeight,

    //изображение
    this.imageProvider,
    this.imageOpacity = 1.0,
  }) {
    // Если текст — выставляем базовые размеры
    if (type == ElementType.text) {
      baseFontSize ??= fontSize ?? 18;
    }
  }

}

extension EditableElementMapper on EditableElement {
  Map<String, dynamic> toJson() {
    return {
      "type": type.toString().split('.').last, // "text", "shape", "image"
      "matrix": matrix.storage.toList().toString(),       // JSON array из 16 чисел
      "rotation_angle": rotationAngle,
      "scale_factor": scaleFactor,
      "width": width,
      "height": height,
      "color": '#${color.value.toRadixString(16).padLeft(8, '0')}',

      // text
      "text": text,
      "font_size": fontSize,
      "base_font_size": baseFontSize,
      "font_family": fontFamily,
      "font_weight": fontWeight == FontWeight.bold ? "bold" : "normal",
      "text_color": '#${textColor.value.toRadixString(16).padLeft(8, '0')}',

      // shape
      "shape_type": shapeType?.toString().split('.').last,

      // image
      "image_url": null, // TODO: заменить ссылкой после загрузки на сервер
      "image_opacity": imageOpacity,
    };
  }
}


class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final Color color;

  ShapePainter({required this.shapeType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    switch (shapeType) {
      case ShapeType.square:
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
        break;

      case ShapeType.circle:
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        canvas.drawOval(rect, paint);
        break;

      case ShapeType.triangle:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
