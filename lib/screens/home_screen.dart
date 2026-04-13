import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../db/database_helper.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Текст киргизүү үчүн контроллерлор (Text editing controllers)
  final _modelController = TextEditingController();
  final _cutController = TextEditingController();
  final _quantityController = TextEditingController();
  final _shipmentController = TextEditingController();
  final _dateController = TextEditingController();

  String _furnituraType = 'Замок'; // Демейки фурнитура
  Color _selectedColor = Colors.black; // Тандалган түс
  String _selectedColorName = 'Кара'; // Түстүн аталышы

  // Түстөрдүн тизмеси (List of colors to pick from)
  final List<Map<String, dynamic>> _colors = [
    {'color': Colors.black, 'name': 'Кара'},
    {'color': Colors.white, 'name': 'Ак'},
    {'color': Colors.grey, 'name': 'Боз'},
    {'color': Colors.red, 'name': 'Кызыл'},
    {'color': Colors.blue, 'name': 'Көк'},
    {'color': Colors.green, 'name': 'Жашыл'},
    {'color': Colors.yellow, 'name': 'Сары'},
    {'color': Colors.brown, 'name': 'Күрөң'},
  ];

  @override
  void initState() {
    super.initState();
    // Демейки күндү коюу (Set default date)
    final today = DateTime.now();
    _dateController.text =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }

  // Түс тандоо диалогун көрсөтүү (Show color picker dialog)
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Түстү тандаңыз'),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors.map((c) {
              final color = c['color'] as Color;
              final name = c['name'] as String;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                    _selectedColorName = name;
                  });
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 18,
                  child: _selectedColor == color
                      ? Icon(
                          Icons.check,
                          color: color == Colors.white
                              ? Colors.black
                              : Colors.white,
                          size: 20,
                        )
                      : (color == Colors.white
                            ? Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                              )
                            : null),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Датаны тандоо функциясы (Date picker function)
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Форманы баштапкы абалга келтирүү (Clear the form)
  void _clearForm() {
    _modelController.clear();
    _cutController.clear();
    _quantityController.clear();
    _shipmentController.clear();
    setState(() {
      _selectedColor = Colors.black;
      _selectedColorName = 'Кара';
      _furnituraType = 'Замок';
    });
  }

  // Форманы маалымат базасына сактоо (Save form to local database)
  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      int cutCount = int.tryParse(_cutController.text) ?? 0;
      int pieceCount = int.tryParse(_quantityController.text) ?? 0;

      // Эгер крой менен штук дал келбесе, эскертүү берүү
      if (cutCount != pieceCount) {
        bool? proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Эскертүү!'),
            content: Text(
              'Крой саны ($cutCount) жана штук саны ($pieceCount) дал келбей жатат. Уланта берелиби?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Жок, оңдойм',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ооба, уланталы'),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }

      final colorHex =
          '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0')}';

      final order = OrderModel(
        userName: widget.userName,
        modelName: _modelController.text.trim(),
        cutQuantity: cutCount,
        color: colorHex,
        pieceQuantity: pieceCount,
        hardwareType: _furnituraType,
        shipmentQuantity: int.tryParse(_shipmentController.text) ?? 0,
        cutDate: _dateController.text,
      );

      await DatabaseHelper.instance.insertOrder(order);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Буйрутма ийгиликтүү сакталды!')),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _clearForm();
    }
  }

  // Радио-баскычты түзүү боюнча жардамчы функция (Helper for radio options)
  Widget _buildRadioOption(String title) {
    return InkWell(
      onTap: () => setState(() => _furnituraType = title),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: title,
            // ignore: deprecated_member_use
            groupValue: _furnituraType,
            // ignore: deprecated_member_use
            onChanged: (val) => setState(() => _furnituraType = val!),
            activeColor: const Color(0xFF4A89DC),
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          ),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _modelController.dispose();
    _cutController.dispose();
    _quantityController.dispose();
    _shipmentController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Дизайндагы ачык боз фон
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A89DC), // Дизайндагы көк түс
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Эгер башкы бет болсо, артка кайтканда тиркемеден чыгып кетет же Splash экранга барат.
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Бирдиктүү блок (Модель атынан баштап Крой кесилгенге чейин)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Модель аты',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _modelController,
                        decoration: InputDecoration(
                          hintText: 'A-102',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A89DC),
                            ),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Милдеттүү' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Канча крой',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: _cutController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: '150',
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              validator: (v) => v!.isEmpty ? 'Жазыңыз' : null,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF0F0F0)),
                      InkWell(
                        onTap: _showColorPicker,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Түсү',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _selectedColorName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 24, color: Color(0xFFF0F0F0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'План штук',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: '140',
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              validator: (v) => v!.isEmpty ? 'Жазыңыз' : null,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF0F0F0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Фурнитура:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _furnituraType,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Фурнитура тандоо радио-баскычтары
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF0F4F8,
                          ), // Дизайндагы көгүш-боз фон
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildRadioOption('Кнопка')),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: _buildRadioOption('Замок')),
                              ],
                            ),
                            const Divider(
                              height: 16,
                              color: Colors.transparent,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildRadioOption('Башка'),
                                ), // Сүрөттө кайталанган Замок, коддогу Башканы калтырдым
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: _buildRadioOption('Экөө тең')),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Канча отправка',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: _shipmentController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: '120',
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              validator: (v) => v!.isEmpty ? 'Жазыңыз' : null,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF0F0F0)),

                      // Крой кесилген дата
                      InkWell(
                        onTap: _selectDate,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Крой кесилген',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.assignment_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _dateController.text.isEmpty
                                      ? 'Дата'
                                      : _dateController.text,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Баскычтар (Buttons section)

                // Сактоо баскычы
                ElevatedButton.icon(
                  onPressed: _saveForm,
                  icon: const Icon(Icons.save, color: Colors.white, size: 22),
                  label: const Text(
                    'Сактоо',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A89DC),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),

                const SizedBox(height: 12),

                // Тазалоо баскычы
                ElevatedButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.grey,
                    size: 24,
                  ),
                  label: const Text(
                    'Тазалоо',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),

                const SizedBox(height: 12),

                // Тарыхча баскычы
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HistoryScreen(userName: widget.userName),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.history_edu,
                    color: Colors.grey,
                    size: 24,
                  ),
                  label: const Text(
                    'Тарыхча',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
