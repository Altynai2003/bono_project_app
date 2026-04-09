import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../db/database_helper.dart';
import 'history_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _modelController = TextEditingController();
  final _cutController = TextEditingController();
  final _quantityController = TextEditingController();
  final _shipmentController = TextEditingController();
  final _dateController = TextEditingController(); // Дата үчүн контроллер

  String _furnituraType = 'Кнопка'; // Фурнитура түрү
  Color _selectedColor = Colors.black; // Тандалган түс

  // Палитра үчүн түстөрдүн тизмеси
  final List<Color> _colors = [
    Colors.black,
    Colors.white,
    Colors.grey,
    Colors.brown,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];

  // Түстү тандоо (Color Picker)
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Түстү тандаңыз',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color);
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 18,
                  // Тандалган түстө чек (галочка) көрсөтүлөт
                  child: _selectedColor == color
                      ? Icon(
                          Icons.check,
                          color: color == Colors.white
                              ? Colors.black
                              : Colors.white,
                          size: 20,
                        )
                      : (color ==
                                Colors
                                    .white // Ак түс айырмаланып турушу үчүн
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

  // Датаны тандоо (Date Picker)
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
            "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      });
    }
  }

  // Форманы тазалоо
  void _clearForm() {
    _formKey.currentState?.reset();
    _modelController.clear();
    _cutController.clear();
    _quantityController.clear();
    _shipmentController.clear();
    _dateController.clear();
    setState(() {
      _selectedColor = Colors.black;
      _furnituraType = 'Кнопка';
    });
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      int cutCount = int.tryParse(_cutController.text) ?? 0;
      int pieceCount = int.tryParse(_quantityController.text) ?? 0;

      // Эгер крой менен штук дал келбесе эскертүү диалогу
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

      // Түстүн кодун алуу #AARRGGBB
      final colorHex = '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0')}';

      // Буйрутма параметрин түзүү
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

      // Маалымат базасына сактоо
      await DatabaseHelper.instance.insertOrder(order);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Маалымат базага ийгиликтүү сакталды!')),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      _clearForm();
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _cutController.dispose();
    _quantityController.dispose();
    _shipmentController.dispose();
    _dateController.dispose(); // Контроллерди эстутумдан өчүрүү
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Жаңы буйрутма'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Отчётко өтүү баскычы
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Отчёт жана Статистика',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              );
            },
          ),
          // Тарыхчага өтүү баскычы
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: 'Тарыхчага өтүү',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen(userName: widget.userName)),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                child: Text(
                  'Салам, ${widget.userName} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Модель маалыматы',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Кандай модель?',
                            prefixIcon: Icon(Icons.checkroom),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Милдеттүү толтурулат'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _showColorPicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.palette_outlined,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Түсү',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: _selectedColor,
                                          shape: BoxShape.circle,
                                          border: _selectedColor == Colors.white
                                              ? Border.all(color: Colors.grey)
                                              : Border.all(
                                                  color: Colors.transparent,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _cutController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Крой саны',
                                  prefixIcon: Icon(Icons.content_cut),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Жазыңыз'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Өндүрүш жана детальдар',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Канча штук чыгат?',
                            prefixIcon: Icon(Icons.format_list_numbered),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Милдеттүү толтурулат'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Фурнитура түрү
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Фурнитура түрү:',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Кнопка'),
                                    selected: _furnituraType == 'Кнопка',
                                    onSelected: (val) => setState(
                                      () => _furnituraType = 'Кнопка',
                                    ),
                                  ),
                                  ChoiceChip(
                                    label: const Text('Замок'),
                                    selected: _furnituraType == 'Замок',
                                    onSelected: (val) => setState(
                                      () => _furnituraType = 'Замок',
                                    ),
                                  ),
                                  ChoiceChip(
                                    label: const Text('Экөө тең'),
                                    selected: _furnituraType == 'Экөө тең',
                                    onSelected: (val) => setState(
                                      () => _furnituraType = 'Экөө тең',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _shipmentController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Канча отправка болот?',
                            prefixIcon: Icon(Icons.local_shipping_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Милдеттүү толтурулат'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Крой кесилген дата
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration: const InputDecoration(
                            labelText: 'Крой кесилген дата',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Милдеттүү толтурулат'
                              : null,
                        ),
                        const SizedBox(height: 32),
                        // Сактоо баскычы
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: const Text(
                              'Сактоо',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Тазалоо баскычы
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _clearForm,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: BorderSide(color: Colors.red.shade400),
                              foregroundColor: Colors.red.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.delete_outline),
                                SizedBox(width: 8),
                                Text(
                                  'Тазалоо',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
