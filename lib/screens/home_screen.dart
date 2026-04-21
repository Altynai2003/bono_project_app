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
    {'color': Colors.purple, 'name': 'Кызгылт көк'},
    {'color': Colors.orange, 'name': 'Кызгылт сары'},
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Түстү тандаңыз',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _colors.map((c) {
                  final color = c['color'] as Color;
                  final name = c['name'] as String;
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        _selectedColorName = name;
                      });
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4A89DC)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 22,
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: color == Colors.white
                                        ? Colors.black
                                        : Colors.white,
                                    size: 24,
                                  )
                                : (color == Colors.white
                                      ? Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        )
                                      : null),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF4A89DC)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A89DC),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A89DC),
              ),
            ),
          ),
          child: child!,
        );
      },
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text('Эскертүү!'),
              ],
            ),
            content: Text(
              'Крой саны ($cutCount) жана штук саны ($pieceCount) дал келбей жатат.\nУланта берелиби?',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Жок, оңдойм',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A89DC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ооба, уланталы',
                  style: TextStyle(color: Colors.white),
                ),
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
              Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Буйрутма ийгиликтүү сакталды!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2ECA7F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          duration: const Duration(seconds: 3),
        ),
      );

      _clearForm();
    }
  }

  // Радио-баскычты түзүү боюнча жардамчы функция (Helper for radio options)
  Widget _buildRadioOption(String title) {
    bool isSelected = _furnituraType == title;
    return GestureDetector(
      onTap: () => setState(() => _furnituraType = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: isSelected
              // ignore: deprecated_member_use
              ? const Color(0xFF4A89DC).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A89DC) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? const Color(0xFF4A89DC)
                  : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4A89DC)
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4A89DC)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF4A89DC).withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
              // ignore: deprecated_member_use
              prefixIcon: icon != null
                  // ignore: deprecated_member_use
                  ? Icon(icon, color: const Color(0xFF4A89DC).withOpacity(0.6))
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF4A89DC),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
            ),
            validator: isRequired
                ? (v) => v!.isEmpty ? 'Бул талааны толтуруу милдеттүү' : null
                : null,
          ),
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
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A89DC), Color(0xFF3b6fc2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: const Color(0xFF4A89DC).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Куш келиңиз',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              Hero(
                tag: 'profile_icon',
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Негизги маалымат (Basic info)
                _buildSectionTitle(
                  'Негизги маалымат',
                  Icons.info_outline_rounded,
                ),
                _buildCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildInputField(
                      label: 'Модель аты (Артикул)',
                      controller: _modelController,
                      hint: 'Мисалы: A-102',
                      icon: Icons.sell_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 2. Сандар (Quantities)
                _buildSectionTitle(
                  'Өлчөмдөр жана Сандар',
                  Icons.format_list_numbered_rounded,
                ),
                _buildCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Крой (кесилген)',
                                controller: _cutController,
                                hint: '150',
                                keyboardType: TextInputType.number,
                                icon: Icons.content_cut_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInputField(
                                label: 'План (штук)',
                                controller: _quantityController,
                                hint: '140',
                                keyboardType: TextInputType.number,
                                icon: Icons.check_box_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'Отправка (жөнөтүлгөн)',
                          controller: _shipmentController,
                          hint: '120',
                          keyboardType: TextInputType.number,
                          icon: Icons.local_shipping_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 3. Деталдар (Details - Color & Hardware)
                _buildSectionTitle('Деталдар', Icons.layers_outlined),
                _buildCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Түсү
                        Text(
                          'Түсү',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _showColorPicker,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _selectedColor,
                                  radius: 12,
                                  child: _selectedColor == Colors.white
                                      ? Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedColorName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(height: 1),
                        ),

                        // Фурнитура
                        Text(
                          'Фурнитура түрү',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildRadioOption('Кнопка'),
                            _buildRadioOption('Замок'),
                            _buildRadioOption('Башка'),
                            _buildRadioOption('Экөө тең'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 4. Дата (Date)
                _buildSectionTitle('Убакыт', Icons.calendar_month_outlined),
                _buildCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Крой кесилген дата',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.today_rounded,
                                  color: Color(0xFF4A89DC),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _dateController.text.isEmpty
                                        ? 'Датаны тандаңыз'
                                        : _dateController.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.edit_calendar_rounded,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 5. Actions (Buttons)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveForm,
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Сактоо',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A89DC),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          // ignore: deprecated_member_use
                          shadowColor: const Color(0xFF4A89DC).withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: _clearForm,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        label: Text(
                          'Тазалоо',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
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
                          Icons.history_rounded,
                          color: Color(0xFF4A89DC),
                          size: 20,
                        ),
                        label: const Text(
                          'Тарыхча',
                          style: TextStyle(
                            color: Color(0xFF4A89DC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          // ignore: deprecated_member_use
                          backgroundColor: const Color(
                            0xFF4A89DC,
                            // ignore: deprecated_member_use
                          ).withOpacity(0.05),
                          side: const BorderSide(
                            color: Color(0xFF4A89DC),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
