import 'package:flutter/material.dart';
import 'package:connect_card/third_party/matrix_gesture_detector.dart';

class VisitCardDesigner extends StatefulWidget {
  const VisitCardDesigner({super.key});

  @override
  State<VisitCardDesigner> createState() => _VisitCardDesignerState();
}

class _VisitCardDesignerState extends State<VisitCardDesigner> {
  final List<EditableTextItem> textItems = [
    EditableTextItem(
      text: 'Барак Обама', 
      matrix: Matrix4.identity(),
      fontSize: 18,
      textColor: Colors.white,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.normal,
    ),
    EditableTextItem(
      text: 'Старший кассир', 
      matrix: Matrix4.identity(),
      fontSize: 18,
      textColor: Colors.white,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.normal,
    ),
    EditableTextItem(
      text: 'ООО KFC', 
      matrix: Matrix4.identity(),
      fontSize: 18,
      textColor: Colors.white,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.normal,
    ),
  ];

  int? selectedIndex;
  String selectedElementType = 'text';
  double fontSize = 18;
  double rotationAngle = 0;
  double width = 100;
  double height = 50;
  Color textColor = Colors.white;
  String fontFamily = 'Roboto';
  FontWeight fontWeight = FontWeight.normal;
  String shapeType = 'rectangle';
  Color shapeColor = Colors.blue;

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
                            onPressed: () => _saveDesign(),
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

          // Кнопки (Выбор текстового поля)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            child: Row(
              children: List.generate(textItems.length, (index) {
                return GestureDetector(
                  onTap: () => _selectTextItem(index),
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
                    child: Text(
                      textItems[index].text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      ),
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
                    //Лист с элементами (пока тут только TextField)
                    ...List.generate(textItems.length, (index) {
                      final item = textItems[index];
                      //Та самая штука, которая позволяет нам перемещать, масштабировать и осуществлять ротацию объектов
                      return MatrixGestureDetector(
                        shouldTranslate: true,
                        shouldScale: true,
                        shouldRotate: true,
                        onMatrixUpdate: (newMatrix, _, __, ___) {
                          setState(() {
                            item.matrix = newMatrix;
                          });
                        },
                        onScaleStart: () {
                          setState(() {
                            selectedIndex = index;
                            selectedElementType = 'text';
                          });
                        },
                        onScaleEnd: () {},
                        child: OverflowBox(
                          minWidth: 0,
                          minHeight: 0,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: Transform(
                            //Нужно для ротации (можно 3,14 вывести как константу, ну особо не важно)
                            transform: Matrix4.rotationZ(
                              textItems[index].rotationAngle * (3.14 / 180)
                            )..multiply(item.matrix),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                  selectedElementType = 'text';
                                });
                              },
                              //Обрамление вокруг выделенного элемента
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: selectedIndex == index && selectedElementType == 'text'
                                      ? Border.all(color: Colors.yellow, width: 2)
                                      : null,
                                ),
                                //Текст, с которым мы работает
                                child: Text(
                                  item.text,
                                  style: TextStyle(
                                    color: item.textColor,
                                    fontSize: item.fontSize,
                                    fontWeight: item.fontWeight,
                                    fontFamily: item.fontFamily,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              )
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (selectedIndex != null && selectedElementType == 'text') ...[
                            // Настройки для текста
                            _buildTextFieldWithFontWeight(),
                            _buildFontFamilyWithColorPicker(),
                            _buildFontSizeSlider(),
                            _buildRotationSlider(),
                          ] else if (selectedElementType == 'shape') ...[
                            // Настройки для фигур
                            _buildCustomSlider('Высота', height, 20, 200, (value) {
                              setState(() => height = value);
                            }),
                            _buildCustomSlider('Ширина', width, 20, 200, (value) {
                              setState(() => width = value);
                            }),
                            _buildShapeDropdownWithColorPicker(),
                            _buildCustomSlider('Размер', fontSize, 8, 36, (value) {
                              setState(() => fontSize = value);
                            }),
                            _buildCustomSlider('Поворот', rotationAngle, 0, 360, (value) {
                              setState(() => rotationAngle = value);
                            }),
                          ],
                        ],
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
                    _buildBottomBarItem(Icons.text_fields, 'Текст', 'text'),
                    _buildBottomBarItem(Icons.crop_square, 'Фигура', 'shape'),
                    _buildBottomBarItem(Icons.image, 'Изображение', 'image'),
                    _buildBottomBarItem(Icons.format_paint, 'Фон', 'background'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem(IconData icon, String label, String type) {
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
                    setState(() => textItems[selectedIndex!].text = value);
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
                value: fontWeight,
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
                    setState(() => textItems[selectedIndex!].fontWeight = value);
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
                value: fontFamily,
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
                    setState(() => textItems[selectedIndex!].fontFamily = value);
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
                          pickerColor: textColor,
                          onColorChanged: (color) {
                            textColor = color;
                          },
                        ),
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
                          color: textColor,
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
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
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
              value: shapeType,
              items: ['rectangle', 'circle', 'triangle', 'oval']
                  .map((shape) => DropdownMenuItem(
                        value: shape,
                        child: Text(
                          shape,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => shapeType = value);
                }
              },
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () async {
                final color = await showDialog<Color>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Выберите цвет'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: shapeColor,
                        onColorChanged: (color) {
                          shapeColor = color;
                        },
                      ),
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
                        color: shapeColor,
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

//Виджет пользовательского слайдера
  Widget _buildCustomSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    final TextEditingController controller = TextEditingController(text: value.toStringAsFixed(1));
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white),
                ),

              const SizedBox(width: 10,),

              SizedBox(
                width: 70,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
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
              divisions: (max - min).toInt(),
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
    return _buildCustomSlider(
      'Размер шрифта', 
      textItems[selectedIndex!].fontSize, 
      8, 
      36, 
      (value) {
        setState(() => textItems[selectedIndex!].fontSize = value);
      },
    );
  }

//Виджет для создания SlideBar для ротации объекта
  Widget _buildRotationSlider() {
    return _buildCustomSlider(
      'Поворот (°)', 
      textItems[selectedIndex!].rotationAngle, 
      -180, 
      180, 
      (value) {
        setState(() => textItems[selectedIndex!].rotationAngle = value);
      },
    );
  }

  void _selectTextItem(int index) {
    setState(() {
      selectedIndex = index;
      selectedElementType = 'text';
    });
  }

  void _saveDesign() {
    debugPrint('Сохранение позиций:');
    for (var item in textItems) {
      debugPrint('${item.text}: ${item.matrix}');
    }
  }
}

class EditableTextItem {
  String text;
  Matrix4 matrix;
  double fontSize;
  Color textColor;
  String fontFamily;
  FontWeight fontWeight;
  double rotationAngle;
  
  EditableTextItem({
    required this.text,
    required this.matrix,
    this.fontSize = 18,
    this.textColor = Colors.white,
    this.fontFamily = 'Roboto',
    this.fontWeight = FontWeight.normal,
    this.rotationAngle = 0,
  });
}

// Заглушка для ColorPicker
class ColorPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      color: Colors.grey[800],
      child: const Center(
        child: Text('Реальный ColorPicker будет здесь', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}